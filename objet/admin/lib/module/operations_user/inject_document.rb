# encoding: UTF-8
class Admin
class Users
class << self

  def exec_inject_document
    nom_doc = medium_value
    nom_doc != nil  || raise('Il faut donner le nom du fichier.')
    nom_doc = nom_doc.as_normalized_filename
    icarien.icmodule   || raise('L’icarien choisi ne possède pas de module courant. Impossible de lui injecter un document d’étape.')
    icarien.icetape    || raise('L’icarien choisi ne possède pas d’étape courant. Impossible de lui injecter un document.')
    absmodule = icarien.icmodule.abs_module
    icetape   = icarien.icetape
    absetape  = icetape.abs_etape

    site.require_objet 'ic_document'
    IcModule::IcEtape::IcDocument.require_module 'create'
    new_doc_id = IcModule::IcEtape::IcDocument.create(icetape, nom_doc, {watcher_upload_comments: true})

    flash "Documnent “#{nom_doc}” (##{new_doc_id}) injecté dans l'étape #{absetape.numero}-#{absetape.titre} du module #{absmodule.name} de #{icarien.pseudo}."+
    "<br>Un watcher a été créé pour le commenter"+
    "<br>Une activité a été produite pour cet envoi"
  rescue Exception => e
    debug e
    error e.message
  end
end #/<< self
end #/Users
end #/Admin
