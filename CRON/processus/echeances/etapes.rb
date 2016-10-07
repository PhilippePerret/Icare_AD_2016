# encoding: UTF-8
class EcheanceEtape
class << self
  # = main =
  #
  # Traitement des échéances de paiement
  def traite
    drequest = {
      where: 'SUBSTRING(options,17,1) = "2"', # actifs
      colonnes: []
    }
    dbtable_users.select(drequest).each do |huser|
      u = User.new(huser[:id])
      puts "Traitement de #{u.pseudo}"
      nombre_jours = (NOW - u.icetape.expected_end) / 1.day
      nombre_jours > 4 || next
      # L'échéance est dépassée de plus de quatre jours
      # ----------------------------------------------
      # On n'envoie un mail que tous les quatres jours de retard
      nombre_jours % 4 == 0 || next

      # On prend le niveau du dernier avertissement
      opts = u.icetape.options || ''
      level_warn = opts[0].to_i + 1
      level_warn < 6 || begin
        # Échéance non modifiée après trop d'avertissements
        # --------------------------------------------------
        # on avertit l'administration
        site.send_mail_to_admin(
          subject:  'Module à arrêter',
          formated:  true,
          message: <<-HTML
          <p>Phil</p>
          <p>Malgré 5 alertes, #{u.pseudo} n'a pas modifié son échéance ou envoyé ses documents de travail…</p>
          <p>Il faut forcer l'arrêt de son module d'apprentissage.</p>
          HTML
        )
        # seulement 5 niveaux d'avertissement. Après, normalement,
        # le module devrait être arrêté ou mis en pause.
        level_warn = 5
      end
      # On envoie le mail
      # -----------------
      # Les mails sont définis dans le dossier :
      # ./objet/ic_etape/lib/mail
      u.send_mail(
        subject:    'Échéance de travail d’étape dépassée',
        formated:   true,
        message:    lire_mail_warning(level_warn, u)
      )
      # On modifie le niveau du dernier avertissement
      u.icetape.set(options: opts.set_bit(0, level_warn))
      log "  - Avertissement de niveau #{level_warn} envoyé à #{u.pseudo} pour un dépassement d'échéance de travail d'étape de #{nombre_jours} jours"
    end
  end

  def lire_mail_warning level_warn, u
    pmail = (IcModule::IcEtape.folder+"lib/mail/depassement_#{level_warn}.erb")
    pmail.deserb(u.bind)
  end

end #/<< self
end #/EcheanceEtape
