# encoding: UTF-8
class Home
class << self
  # ---------------------------------------------------------------------
  #   Méthodes d'helper pour constuire la page d'accueil
  # ---------------------------------------------------------------------

  def presentation_atelier
    (
      "L’ATELIER ICARE est un <strong>atelier d’écriture en ligne</strong> proposant un accompagnement professionnel de tout projet d’histoire (scénario, roman, BD…) ainsi qu’un ap&shy;pren&shy;tis&shy;sage de la narration et de la dramaturgie, de la simple ini&shy;tia&shy;tion jusqu’au perfectionnement." +
      bouton_presentation_complete
    ).
    in_div(id: 'presentation_atelier')
  end
  def bouton_presentation_complete
    'PRÉSENTATION COMPLÈTE'.in_a(href: 'overview/home', class: 'btn main block')
  end


  def bouton_modules_dapprentissage
    (
      (bouton_reussites + bouton_temoignages).in_div(class: 'liens_reussites_temoignages') +
      'MODULES PROPOSÉS'.in_a(href: 'abs_module/list', class: 'btn main').in_div(id: 'div_btn_modules') +
      bouton_icariens.in_div(class: 'lien_icariens')
      ).in_div(id: 'boutons_icariens')
  end
  def bouton_reussites
    'RÉUSSITES'.in_a(href: 'overview/reussites')
  end
  def bouton_temoignages
    'TÉMOIGNAGES'.in_a(href: 'overview/temoignages')
  end
  def bouton_icariens
    'ICARIENNES ET ICARIENS'.in_a(href: 'icarien/list')
  end




  def separation
    '<div style="clear:both"></div>'+
    '<div class="separation"></div>'
  end

end #/<< self
end #/Home
