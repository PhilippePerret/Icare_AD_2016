# encoding: UTF-8
=begin

  Module de téléchargement d'un document QDD. Il est appelé par :

      quai_des_docs/<id ic-document/download

  Le formulaire qui appelle cette route doit contenir :

    checksum      Le checksum des un ou deux documents à télécharger

  Pour pouvoir télécharger les documents, il faut :

    - être administrateur (tous privilèges)
    - être vrai icarien
    - être icarien à l'essai mais ne pas avoir téléchargé plus de 5
      documents

    - que le document soit partagé (sauf si l'icarien est sur la
      même étape que le document)
=end
# BARRIÈRE MAUVAIS USER
raise_unless_identified


site.require_objet 'ic_document'

def icdoc
  @icdoc ||= begin
    IcModule::IcEtape::IcDocument.new site.current_route.objet_id
  end
end

def data_download
  @data_download ||= param(:download)
end

# True si le document est de la même étape que l'icarien. Dans ce
# cas-là, même non partagé, il peut être lu.
def same_etape_icarien?
  @is_same_etape_icarien ||= begin
    if user.icetape
      icdoc.icetape.id == user.icetape.id
    else
      false
    end
  end
end

# Retourne true si le document existe vraiment et si son niveau de
# partage est suffisant
def need? ty
  icdoc.exist?(ty) && ( icdoc.shared?(ty) || same_etape_icarien? || user.admin?)
end

# Dossier de téléchargement
def download_folder
  @download_folder ||= begin
    d = site.folder_tmp + "download/qdd/document_#{icdoc.id}"
    FileUtils.rm_rf d.to_s
    `mkdir -p "#{d}"` # Création du dossier
    d
  end
end

# {SuperFile} Path du fichier téléchargeable
def download_path ty
  download_folder + icdoc.qdd_name(ty)
end

# Copie le document original dans son dossier de téléchargement
def copy_in_download_folder ty
  FileUtils.cp icdoc.qdd_path(ty).expanded_path, download_path(ty).expanded_path
end

begin

  # BARRIÈRE ICARIEN À L'ESSAI ET TROP DE TÉLÉCHARGEMENTS
  # Note : si l'user a déjà lu (téléchargé) ce document, il n'y a aucun
  # test à faire, il peut le télécharger autant de fois qu'il veut
  user_a_lu_ce_document = user.lu?(icdoc.id)
  user_a_lu_ce_document || begin
    if user.alessai? && user.nombre_lectures >= 5
      raise "Désolé, mais en tant qu’icarien#{user.f_ne} à l’essai, vous n’êtes autorisé#{user.f_e} à consulter que 5 paires de documents (original + commentaires). Ce nombre sera illimité dès que vous deviendrez vrai#{user.f_e} icarien#{user.f_ne}, c'est-à-dire juste après votre premier paiement (que vous pouvez bien entendu anticiper en en #{lien.contact('faisant la demande à Phil')})."
    end
  end

  # BARRIÈRE MAUVAIS CHECKSUM
  icdoc.checksum == data_download[:checksum] || raise('Chercheriez-vous à télécharger illégalement des documents de l’atelier Icare ?…')

  need?(:original) || need?(:comments) || raise('Vous n’êtes pas autorisé à charger ces documents.')

  # -----------------------------------------------------------------
  #   Tout est bon, on peut prépare le téléchargement des documents
  # -----------------------------------------------------------------

  need?(:original) && copy_in_download_folder(:original)
  need?(:comments) && copy_in_download_folder(:comments)

  # Dans tous les cas on met dans le dossier un fichier rappelant
  # l'avertissement de ne pas partager
  pfile_avertissement = download_folder + 'AVERTISSEMENT.txt'
  pfile_avertissement.write QuaiDesDocs.avertissement

  # Juste avant le téléchargement, on enregistre cette "lecture" pour le
  # document et l'user, et on crée un watcher pour que l'user puisse
  # commenter sa lecture.
  user_a_lu_ce_document || begin
    icdoc.add_lecture
    user.add_watcher(objet: 'quai_des_docs', objet_id: icdoc.id, processus: 'cote_et_commentaire')
  end

  # On donne le zip à downloader à l'icarien
  download_folder.download

rescue Exception => e
  debug e
  error e.message
ensure
  redirect_to :last_route
end
