# encoding: UTF-8
class Home
class << self

  def presentation_phil
    (
      conteneur_medaillon_phil        +
      presentation_texte_phil         +
      bouton_modules_dapprentissage
    ).in_div(id: 'presentation_phil')
  end

  def conteneur_medaillon_phil
    '<img id="medaillon" src="view/img/atelier/phil-medaillon.png" />'.in_div(id: 'conteneur_medaillon')
  end
  def presentation_texte_phil
    "L'atelier Icare est animé par <strong>Philippe Perret</strong>, scénariste professionnel, romancier (<a href=\"http://livre.fnac.com/a1451727/Philippe-Perret-Mort-vivant\" target='_blank'>mort@vivant</a>, Ed. Anne Carrière), compositeur, musicien et pé&shy;da&shy;go&shy;gue passionné (auteur de <a href=\"http://www.amazon.fr/Savoir-Rédiger-Presenter-Son-Scenario/dp/1090461054\" target=\"_blank\">Savoir rédiger et pré&shy;sen&shy;ter du scénario</a>).".in_div(id: 'presentation_texte')
  end

end#/<< self
end #/Home
