# encoding: UTF-8
class QuaiDesDocs
class << self

  # Le message d'avertissement à placer au-dessus de toute liste de
  # documents et également dans un fichier "AVERTISSEMENT.txt" dans
  # les dossiers de téléchargement
  def avertissement
    <<-TXT
Veuillez bien noter, #{user.pseudo}, que ces documents sont strictement réservés à votre usage personnel au sein de l'atelier et ne doivent EN AUCUN CAS, sauf autorisation expresse de leurs auteures ou auteurs, être transmis à un tiers ou utilisés à vos propres fins.

Merci pour les auteures et auteurs, comme vous, qui ont produit ce travail relevant de la propriété intellectuelle.
    TXT
  end

  def avertissement_alessai_if_needed
    user.alessai? || (return '')
    nb = user.nombre_lectures
    nb_reste = 5 - nb
    s = nb > 1 ? 's' : ''
    (
      'En tant que simple icarien à l’essai, vous n’êtes en mesure que de charger 5 documents du Quai des docs.'+
      "Vous êtes actuellement à #{nb} document#{s} téléchargé#{s}, il vous en reste donc <strong>#{nb_reste}</strong> à télécharger."
    ).in_div(id: 'warning_alessai', class: 'small italic red')
  end

end #/<< self
end #/QuaiDesDocs
