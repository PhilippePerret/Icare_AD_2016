# encoding: UTF-8

def icdocument
  @icdocument ||= instance_objet
end

def icetape
  @icetape ||= icdocument.icetape
end

# Dossier où se trouvent les documents commentaires à
# télécharger par l'icarien
def folder_download
  @folder_download ||= site.folder_tmp + "download/owner-#{owner.id}-upload_comments-#{owner.icmodule.id}-#{icetape.id}"
end
