# encoding: UTF-8
=begin

  Module principal qui permet de télécharger le document.

=end


# Marquer le document original téléchargé
# Noter que puisque c'est l'administrateur qui télécharge, il s'agit
# forcément du document original
icdocument.set(options: icdocument.options.set_bit(2,1))

# Le dossier contenant le document (attention ! il peut en contenir plusieurs)
#
# Deux cas peuvent se produire : soit l'user est en cours de travail et
# c'est un envoi de travail sur une étape, soit ce sont les documents
# d'inscription.
#
def folder_document
  @folder_document ||= begin
    if owner.icmodule_id.nil?
      # Inscription
      site.folder_tmp + "download/user-#{owner.id}-signup"
    else
      # Envoi de travail
      site.folder_tmp+"download/owner-#{owner.id}-send_work-etape-#{icetape.abs_etape.numero}"
    end
  end
end

# Passer l'étape au status 3 mais seulement si tous les
# documents ont été téléchargés.
all_document_received = true
icetape.documents.split(' ').each do |docid|
  idoc = IcModule::IcEtape::IcDocument.new(docid.to_i)
  if idoc.options[2].to_i == 0
    all_document_received = false
    break
  end
end
all_document_received && icetape.set(status: 3)

# Création du watcher suivant. Il s'agit du dépot de commentaire
owner.add_watcher(
  objet:      'ic_document',
  objet_id:   objet_id,
  processus:  'upload_comments'
)

# Donner le document en téléchargement
(folder_document+icdocument.original_name).download
