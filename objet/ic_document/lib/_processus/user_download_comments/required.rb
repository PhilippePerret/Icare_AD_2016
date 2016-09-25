# encoding: UTF-8

# Raccourcis
def icdocument; @icdocument ||= instance_objet      end
def icetape;    @icetape    ||= icdocument.icetape  end

def inscription?
  @for_inscription = icdocument.icetape_id.nil? if @for_inscription === nil
  @for_inscription
end
# Dossier où se trouvent les documents commentaires à
# télécharger par l'icarien
# Attention, ici, il ne faut plus prendre les informations dans le
# module de l'icarien (son étape a dû changer) mais dans les informations
# du document.
def folder_download
  if inscription?
    site.folder_tmp + "download/user-#{owner.id}-signup"
  else
    site.folder_tmp + "download/owner-#{owner.id}-upload_comments-#{icetape.icmodule_id}-#{icetape.id}"
  end
end
