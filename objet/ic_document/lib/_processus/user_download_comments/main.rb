# encoding: UTF-8


# Marqué le document commentaire téléchargé
# Noter que puisque c'est l'user qui télécharge le document, il s'agit
# forcément du document commentaire
icdocument.set(options: icdocument.options.set_bit(10,1))

# Watcher suivant : pour déposer les documents sur le QDD
# NOTES
#   * Il s'agit des deux documents, l'original et le commentaire, mais
#     on peut faire ça en un seul watcher.
owner.add_watcher(
  objet:      'ic_document',
  objet_id:   objet_id,
  processus:  'depot_qdd'
)

# Donner le document commentaires à downloader
sfile = folder_download + "#{icdocument.doc_affixe}_comsPhil.odt"
sfile.download

# Pour le mail, on doit s'assure que tous les documents ont été traités
# (tous les documents de l'étape du document courant)
docs_ids = icetape.documents.split(' ').collect{|n| n.to_i}
hdocuments = dbtable_icdocuments.select(where: "id IN (#{docs_ids.join(', ')})", colonnes: [:options, :original_name])
all_documents_traited = true
hdocuments.each do |hdoc|
  opts = hdoc[:options]
  if opts[8].to_i == 1 && opts[10].to_i == 0
    # <= un document pas encore traité (qui a des commentaires mais
    # qui n'a pas encore été downloadé)
    all_documents_traited = false
    break
  end
end

# Tant que tous les documents n'ont pas été traités, on ne peut
# pas envoyer le mail admnistrateur informant que les commentaires
# ont été téléchargés
all_documents_traited || no_mail_admin

# Si tous les documents ont été traités, l'étape peut passer
# au statut suivant (status)
all_documents_traited && begin
  icetape.set(status: 5)
  # Il faut faire les watchers de dépôt QDD pour chaque
  # document.
  hdocuments.each do |hdoc|
    owner.add_watcher(
      objet:      'ic_document',
      objet_id:   hdoc[:id],
      processus:  'depot_qdd'
    )
  end
end

flash "Bonne lecture à vous, #{owner.pseudo} !"
