# encoding: UTF-8
class EcheancePaiement
class << self

  # = main =
  #
  # Traitement des dépassements d'échéances de paiement
  # On ne traite que les icariens actifs
  def traite
    drequest = {
      where: 'SUBSTRING(options,17,1) = "2"', # actifs
      colonnes: []
    }
    dbtable_users.select(drequest).each do |huser|
      u = User.new(huser[:id])
      # On ne prend que les icariens qui ont un paiement à
      # effectuer
      u.icmodule.next_paiement != nil || next
      nombre_jours = (NOW - u.icmodule.next_paiement) / 1.day
      # Si l'icarien est à plus de 4 jours de retard d'échéance,
      # on le traite.
      nombre_jours > 4 || next
      # On envoie un mail à l'icarien tous les 5 jours
      nombre_jours % 5 || next
      level_warn = 1 + u.bit_echeance_paiement
      # Il y a 5 niveau d'alerte. Au bout du 5e niveau, on avertit
      # l'administration
      level_warn < 5 || begin
        site.send_mail_to_admin(
          subject:  'Paiement non effecuté',
          formated:  true,
          message: <<-HTML
<p>Phil,</p>
<p>L'icarien #{u.pseudo} (##{u.id}) a reçu 5 alertes concernant son dépassement d'échéance de paiement, sans réponse.</p>
<p>Il faut à présent procéder à sa radiation de l'atelier…</p>
          HTML
        )
        level_warn = 5
      end

      # On envoie le mail
      # -----------------
      # Les mails sont définis dans le dossier :
      # ./objet/ic_etape/lib/mail
      u.send_mail(
        subject:    "Dépassement d'échéance de paiement",
        formated:   true,
        message:    lire_mail_warning(level_warn, u)
      )
      
      # On modifie le niveau du dernier avertissement
      u.set(options: u.options.set_bit(25, level_warn))

      log "  - Avertissement de niveau #{level_warn} envoyé à #{u.pseudo} pour un DÉPASSEMENT D'ÉCHÉANCE DE PAIMENT de #{nombre_jours} jours."
    end
  end
  #/traite

  def lire_mail_warning level_warn, u
    pmail = (site..folder_objet+"user/lib/mail/depassement_paiement_#{level_warn}.erb")
    pmail.deserb(u.bind)
  end

end #/<< self
end #/EcheancePaiement
