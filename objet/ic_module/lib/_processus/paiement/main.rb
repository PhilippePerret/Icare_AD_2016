# encoding: UTF-8
=begin

  Processus de paiement du module.

  Noter que ce module n'est pas appelé classiquement par la route du
  formulaire, car l'action du formulaire est `paiement/main`.
  Bien plutôt, c'est le module 'paiement/main' qui "run" ce watcher
  quand tout s'est bien passé pour pouvoir
    1/ Envoyer les mails
    2/ Détruire ce watcher

=end

# Si le module est de type suivi, il faut créer un nouveau watcher dans
# un mois
date_next_paiement =
  if icmodule.abs_module.type_suivi?
    dnext_paiement = icmodule.next_paiement + 1.month
    owner.add_watcher(
      objet:      'ic_module',
      objet_id:   objet_id,
      processus:  'paiement',
      triggered:  dnext_paiement - 3.days
    )
  else
    nil
  end

# Il faut enregistrer l'ID de ce paiement dans l'ic-module
# Note : il est mis dans param(:paie_id) par le module de paiement.
# OBSOLETE : l'opération est faite à l'enregistrement du paiement
# dans lib/module/on_paiement_ok/main.rb
# paies = ( (icmodule.paiements||'') + " #{param(:paie_id)}" ).strip

# Modification des données du module icarien
icmodule.set(
  next_paiement:  date_next_paiement
  )

# Si c'était un icarien à l'essai, il faut le mettre à vrai
# Noter que cette méthode arrive après la formation du message qui s'affiche
# suite au paiement (cf. ./objet/ic_paiement/lib/module/on_paiement_ok/helper.rb)
if owner.alessai?
  owner.set(options: owner.options.set_bit(24,1))
  # ANNONCER ce(tte) nouvel(le) icarcien(ne)
  site.require_objet 'actualite'
  message = "<strong>#{owner.pseudo}</strong> devient un#{owner.f_e} <em>vrai#{owner.f_e}</em> icarien#{owner.f_ne}."
  SiteHtml::Actualite.create(
    message:  message,
    user_id:  owner.id
  )
end



# Ensuite, un mail sera envoyé à l'administration et à l'icarien(ne)
