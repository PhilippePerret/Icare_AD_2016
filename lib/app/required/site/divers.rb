# encoding: UTF-8
class SiteHtml

  # {SuperFile} Le fichier HTML consignant les toute dernières actualités
  # pour ne pas avoir à le reconstruire chaque fois.
  #
  # Ce fichier est détruit dès qu'on ajoute une actualité
  #
  def file_last_actualites
    @file_last_actualites ||= folder_objet + 'actualite/listing_home.html'
  end

end #/SiteHtml
