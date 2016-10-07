# encoding: UTF-8
class Admin
class Overview
class << self

  # = main =
  #
  # Méthode principale affichant l'aperçu de tous les icariens
  # en activité
  #
  def display
    @drequest = {
      where:    'SUBSTRING(options,17,1) = "2"',
      colonnes: []
    }
    # On relève les informations sur les icariens en consignant dans les
    # jours :
    #   - le début de l'étape
    #   - la fin attendue du travail (si étape status et < ???)
    #   - la fin attendue des commentaires (si status > ???)
    @hash_data = Hash.new
    dbtable_users.select(@drequest).each do |huser|
      u = User.new(huser[:id])
      icetape = u.icetape
      next if icetape.nil?
      statut_etape  = icetape.status
      start_date = Time.at(icetape.started_at)
      key_start = inverse_date(start_date)
      @hash_data.key?(key_start) || @hash_data.merge!(key_start => Array.new)
      @hash_data[key_start] << {start: icetape}
      # Est-ce que c'est un travail qui est attendu ou un
      # commentaire.
      if statut_etape == 1
        # Travail attendu
        work_date = Time.at(icetape.expected_end)
        key_work = inverse_date(work_date)
        @hash_data.key?(key_work) || @hash_data.merge!(key_work => Array.new)
        @hash_data[key_work] << {work: icetape}
      elsif statut_etape > 1
        # Commentaires attendus
        if icetape.expected_comments.nil?
          # UNE ERREUR
          debug "# expected_comments NON DÉFINI (pour #{u.pseudo} ##{u.id})"
        else
          comments_date = Time.at(icetape.expected_comments)
          key_comments = inverse_date(comments_date)
          @hash_data.key?(key_comments) || @hash_data.merge!(key_comments => Array.new)
          @hash_data[key_comments] << {comments: icetape}
        end
      end
    end
    # On construit la grille en mettant les étapes
    display_grid +
    # En dessous, un aperçu textuel
    overview_textuel
  end

  def inverse_date d
    y = d.year
    m = d.month.to_s.rjust(2,'0')
    d = d.day.to_s.rjust(2,'0')
    "#{y}#{m}#{d}"
  end

  # Affiche la portion de calendrier de trois mois qui
  # permet de visualiser les icariens
  # ET insert les icariens dans les jours
  #
  def display_grid
    now   = Time.now
    t = String.new
    t << '<div class= "calrow">'
    start = Time.now.to_i - 30.days
    93.times do |njour|
      thisdate = Time.at(start + njour.days)
      key_this_date = inverse_date(thisdate)
      content =
        if @hash_data.key?(key_this_date)
          # Pour régler la hauteur
          nombre_elements = @hash_data[key_this_date].count
          top =
            if nombre_elements == 1
              -8
            else
              -20
            end

          @hash_data[key_this_date].collect do |arr|
            type = arr.keys.first
            # Pour régler la hauteur
            # Pour régler la mark
            mark =
              case type
              when :start     then 'D'
              when :work      then 'W'
              when :comments  then 'C'
              end.in_span(class: "calmark #{type}", style: "top:#{top}px;")
            top += 23
            mark
          end.join(', ')
        else
          ''
        end
      debug "content : #{content.inspect}"
      if njour == 0
        t << "<div class='calmonth'>#{Fixnum::MOIS_LONG[thisdate.month]}</div>"
      end
      jour_courant = now.month == thisdate.month && now.day == thisdate.day

      classe_day = ['calday']
      false == jour_courant || classe_day << 'current'
      if thisdate.day == 1
        # On met la rangée pour le mois et on
        # commence une nouvelle rangée de jours
        t << '</div>'
        t << "<div class='calmonth'>#{Fixnum::MOIS_LONG[thisdate.month]}</div>"
        t << '<div class= "calrow">'
      end
      t << "<div class='#{classe_day.join(' ')}'>#{content}#{thisdate.day.to_s.in_span(class: 'markday')}</div>"
    end
    # /Fin de boucle sur ~ 93 jours
    t << '</div>' # pour fermer la rangée calrow
    t.in_div(class: 'cal')
  end
  # /display_grid


  def overview_textuel
    dbtable_users.select(@drequest).collect do |huser|
      begin
        User.new(huser[:id]).overview
      rescue Exception => e
        debug e
        ''
      end
    end.join('').in_div(class: 'users_overview')
  end

end #/<< self
end #/Overview
end #/Admin
