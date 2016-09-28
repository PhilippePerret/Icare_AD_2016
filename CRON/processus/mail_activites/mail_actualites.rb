#!/usr/bin/env ruby
# encoding: UTF-8

class Cron

  # Pour appeler le processus par le cron
  def _mail_activites
    Cron::Activites.mail_activites
  end

  class Activites

    # Les mails à retirer des envois, pour différentes raisons à commencer
    # par le fait que l'adresse n'existe plus.
    MAILS_OUT = [
      'domideso@hotmail.fr', 'rocha_dilma@hotmail.com',
      'mahidalila@aol.com'
    ]

    class << self

      # = main =
      #
      # Méthode principale qui envoie les mails d'activité à tous les
      # icariens qui en ont fait la demande et tous les actifs.
      #
      # Noter que les librairies du site ne sont pas chargées, dans la nouvelle
      # version du cron. Le cron implémente une version minimale des méthodes et
      # des classes.
      #
      def mail_activites
        reset
        log "<hr />"
        log "---> Envoi des mails d'actualite de la veille", {time: true}
        if mode_test?
          log "MODE TEST --- Les mails ne seront pas vraiment envoyes"
        end

        # S'il n'y a aucune actualité trouvée pour la veille, on peut
        # s'en retourner aussitôt
        if actualites_veille.empty?
          log "= Aucune actualite trouvée pour hier."
          return
        end

        log "*** ENVOI DES MESSAGES D'ACTUALITE ***", {time: true}
        if destinataires.nil?
          log "`destinataires` est nil (ce qui ne devrait jamais arriver)...\n"+
          "J'essaie de corriger l'erreur ou je renonce si je n'y parviens pas."
          return
        end

        # ----------------------------
        # BOUCLE D'ENVOI DES MESSAGES
        # ----------------------------
        log "- POUR LE MOMENT, LES MAILS NE SONT ENVOYÉS QU'À PHIL"
        # cf. def destinataires ci-dessous
        destinataires.each do |u|
          next if MAILS_OUT.include?(u.mail)
          send_mail_to u
          log "--- Message sent to: #{u.pseudo}"
        end

      rescue Exception => e
        debug e
        false
      else
        # Tout s'est bien passé, on marque que les actualités ont
        # été envoyées aux users
        mark_activites_envoyees
        true
      end

      def send_mail_to u
        data_mail = {
          subject:        "Dernières actualités de l'atelier Icare",
          message:        (message_template % {pseudo: u.pseudo}).force_encoding('utf-8')
        }
        u.send_mail(data_mail)
      end

      # On marque les activités envoyées
      def mark_activites_envoyees
        actu_ids = actualites_veille.collect{|h| h[:id]}.join(', ')
        dbtable_activites.update({where: "id IN (#{actu_ids})"}, {status: 2})
        log "-- Activités marquées envoyées par mail quotidien"
      end

      # Raccourci pour savoir si on est en mode test
      def mode_test?; cron.mode_test? end

      # Retourne les actualités de la veille, sous forme de Array
      # En mode test, s'il n'y a aucune actualité, on en crée
      def actualites_veille
        @actualites_veille ||= begin
          # cond_where = "status = 1"
          cond_where = '1 = 1' # pour essai
          arr = dbtable_actualites.select(where:cond_where)
          arr.sort_by { |ac| ac[:created_at] }
        end
      end

      # Retourne la liste {Array} des {Hash} de données des icariens qui
      # veulent ou qui doivent recevoir les mails d'activité
      def destinataires
        @destinataires ||= begin
          # TODO Quand ce sera OK on pourra renvoyer les mails
          # drequest = {
          #   where: "SUBSTRING(options,4,1) = '0'" # pas détruit
          #   colonnes: []
          # }
          # dbtable_users.select(colonnes:[]).collect do |udata|
          #   u = User.new(udata[:id])
          #   (u.actif? || u.bit_mail_actu == 0) ? u : nil
          # end.compact
          [User.new(1)]
        end
      end

      # ---------------------------------------------------------------------
      #   Méthodes de dates et de temps
      # ---------------------------------------------------------------------

      # RETURN Un {Hash} contenant :start et :end, les dates
      # de debut et de fin de la veille
      #
      def hier
        @hier ||= begin
          n = Time.now
          today = Time.new(n.year, n.month, n.day)
          {
            start:  ( today - 1.day ).to_i,
            end:    today.to_i - 1
          }
        end
      end

      # ---------------------------------------------------------------------
      #   Méthodes pour la composition du message
      # ---------------------------------------------------------------------

      # {String} Code HTML de la liste des actualités de la veille
      def listing_actualites_veille
        "<ul id='actualites'>#{actualites_as_li}</ul>"
      end
      def actualites_as_li
        actualites_veille.collect do |dactu|
          li = <<-HTML
          <li class='li_actu_mail'>
            <span class='actu_heure'>#{Time.at(dactu[:created_at]).strftime("%H:%M")}</span>
            <span class='actu_actu'>#{dactu[:message]}</span>
          </li>
          HTML
          li.gsub(/\n/,"")
        end.join("\n")
      end

      # Le message template qui sera adapté à chaque icarien qui doit
      # recevoir les actualités
      def message_template
        @message_template ||= <<-EOC
#{stylesheet}
<p>Bonjour %{pseudo},</p>
<p>Trouvez ci-dessous la liste des dernières activités de l'atelier Icare.</p>
#{listing_actualites_veille}
<hr />
<p style="font-size:9pt;">Pour ne plus recevoir ces messages lorsque vous n'êtes pas actif, rejoignez <a href='http://www.atelier-icare.net/bureau'>votre bureau</a> et réglez vos préférences.</p>
<p>Bien &agrave; vous,</p>
          EOC
      end

      def stylesheet
        @stylesheet ||= <<-EOC
  <style type="text/css">
  .actu_heure {
    color: #008080;
    font-family: Georgia,Courier;
    margin-right: 1em;
  }
  ul#actualites {
    list-style: square outside url('#{url_images_folder}/icones/coche.png');
    margin-left:2em;
  }
  ul#actualites span.actu_heure {
  float:left;
  margin-top:-3px;
  }
  ul#actualites span.actu_actu {
  display:block;
  margin-left:3em;
  }
  </style>

        EOC
      end

      def quatre_fausses_actualites
        [
          {:message => "La dernière actualités, mais qui doit être la première a 5 minutes", created_at: (hier[:start] + 5*60)},
          {:message => "Actualités virtutelles pour tests hier a 10 heures", created_at: (hier[:start] + 10*3600)},
          {:message => "Une autre actualités pour tests hier a 5 heures 30 du matin", created_at: (hier[:start] + 5*3600 + 1800)},
          {:message => "La toute première a 1h20 pour tests", created_at: (hier[:start] + 3600+20*60)}
        ]
      end

      def reset
        [:div_citation, :message_template].each do |key|
          instance_variable_set("@#{key}", nil)
        end
      end

    end # << self
  end # /Activites
end # / Cron
