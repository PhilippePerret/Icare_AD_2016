# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # Pour downloader le document de travail (pas le document QDD)
  #
  # Rappel : le document se trouve toujours dans le dossier :
  #   ./tmp/download/user-<id user>/ (cf. ci-dessous)
  def download_original ; path_download_file(:original).download end
  def download_comments ; path_download_file(:comments).download end

  def path_download_file ty = :original
    folder_download + "#{doc_affixe}#{ty == :original ? '' : '_comsPhil'}.#{extension}"
  end

  def folder_download
    @folder_download ||= site.folder_tmp + "download/user-#{user_id}"
  end


end #/IcDocument
end #/IcEtape
end #/IcModule
