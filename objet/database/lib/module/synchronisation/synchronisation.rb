# encoding: UTF-8
class Database
class Table
class << self

  # = main =
  #
  # Méthode principale pour procéder à la synchronisation des tables
  # online et offline.
  #
  def _synchronize
    if param(:confirmed).nil?
      message_confirmation
    else
      proceed_synchronisation
    end
  rescue Exception => e
    debug e
    "ERREUR DANS LA SYNCHRONISATION : #{e.message} (détail dans le fichier debug)"
  end

  def message_confirmation
    m = String.new
    m << "Il faut procéder à la synchronisation #{sens_humain}"
    params[:where].nil? || begin
      m << "\nLes rangées à synchroniser doivent répondre au filtre : <span class='red'>#{params[:where].inspect}</span>. "
    end
    params[:columns].nil? || begin
      m << "Seules les colonnes <span class='red'>#{params[:columns].inspect}</span> seront affectées (les autres garderont leur valeur)"
    end
    m << 'Confirmer la synchronisation'.in_a(onclick: "$.proxy(Database,'confirm_synchronisation')()", class: 'btn').in_div(class: 'right')
  end

  def params
    @params ||= begin
      w = param(:filter).nil_if_empty
      w.nil? || begin
        w = w.start_with?('{') ? eval(w) : w
      end
      c = param(:columns).nil_if_empty
      c.nil? || begin
        c = c.split(',').collect{|e| e.strip.to_sym}
      end
      {
        base:       param(:dbname),
        table:      param(:tblname),
        sens:       param(:sens_synchro), # d2l ou l2d
        where:      w,
        columns:    c,
        pure_mysql: param(:pure_mysql) == 'on'
      }
    end
  end

  def sens_humain
    @sens_humain ||= begin
      "de :\n\n\t\t" +
      if params[:sens] == 'd2l'
        "<strong>la table distante `#{table_designation}` (source)</strong>"
      else
        "<strong>la table locale `#{table_designation}` (source)</strong>"
      end +
      "\n\nvers :\n\n\t\t" +
      if params[:sens] == 'd2l'
        "la table locale (destination)"
      else
        "la table distante (destination)"
      end + "\n"
    end
  end

  def table_designation
    @table_designation ||= "#{site.prefix_databases}_#{params[:base]}.#{params[:table]}"
  end



  # ---------------------------------------------------------------------
  #
  #     SYNCRHONISATION
  #
  # ---------------------------------------------------------------------

  # = main =
  #
  # Méthode principale qui procède vraiment à la synchronisation
  #
  def proceed_synchronisation
    resultat = Array.new
    resultat << "=== SYNCHRONISATION #{Time.now} ==="
    resultat << "=== BASE  : #{params[:base]}"
    resultat << "=== TABLE : #{params[:table]}"
    resultat << "=== SENS  : #{params[:sens] == 'd2l' ? 'distante vers locale' : 'locale vers distante'}"
    resultat << ""
    table_online  = site.dbm_table(params[:base], params[:table], online = true)
    table_offline = site.dbm_table(params[:base], params[:table], online = false)

    table_src, table_des =
      if params[:sens] == 'd2l'
        [table_online, table_offline]
      else
        [table_offline, table_online]
      end

    drequest = Hash.new

    # Récupérer les rangées en fonction des filtres éventuels
    if params[:where]
      drequest.merge!(where: params[:where])
    end
    if params[:columns]
      drequest.merge!(colonnes: params[:columns])
    end

    resultat << "drequest : #{drequest.inspect}"
    rows_src = table_src.select(drequest)

    des_colonnes =
      if params[:columns].nil?
        ""
      else
        " des colonnes #{params[:columns].collect{|c| ":#{c}"}.pretty_join}"
      end

    resultat << "\n"+ "-"*80+"\n"
    # === On procède à la synchronisation
    rows_src.each do |row_src|
      row_id = row_src[:id]
      resultat << "* Synchronisation#{des_colonnes} de la rangée ##{row_id}"
      if params[:columns].nil? || table_des.count(where:{id: row_id}) == 0
        table_des.delete(row_id)
        table_des.insert(row_src)
      else
        new_data = Hash.new
        params[:columns].each do |column|
          new_data.merge!(column => row_src[column])
        end
        table_des.update(row_id, new_data)
      end

    end
    resultat << "\n"+ "-"*80+"\n"

    resultat.join("\n")
  end
end #/<< self
end #/Table
end #/Database
