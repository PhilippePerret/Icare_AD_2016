# encoding: UTF-8
=begin

  Ce module permet de procéder au changement d'étape après que Phil
  aie choisi l'étape.

=end

# L'icetape précédente doit être enregistré dans la donnée
# icetapes de l'icmodule
begin
  site.require_objet 'ic_etape'

  etapes = (icmodule.icetapes || "").split(' ')
  etapes << icetape.id
  etapes = etapes.join(' ')


  new_icetape = IcModule::IcEtape.create_for icmodule, next_abs_etape.numero

  icmodule.set(
    icetapes:     etapes,
    icetape_id:   new_icetape.id
  )

  # Un watcher pour rendre le travail de cette étape
  owner.add_watcher(
    objet:      'ic_etape',
    objet_id:   new_icetape.id,
    processus:  'send_work'
  )

  flash "Changement d'étape opéré pour #{owner.pseudo} (#{owner.id})" +
     "<br>---------------------------------------------------------" +
    "<br>Ancienne : #{absetape.numero} : #{absetape.titre}" +
    "<br>Nouvelle : #{new_icetape.abs_etape.numero} : #{new_icetape.abs_etape.titre}"

rescue Exception => e
  debug e
  dont_remove_watcher
  no_mail_user
  error "Une erreur est survenue : #{e.message}."
end
