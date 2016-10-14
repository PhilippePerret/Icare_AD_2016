# encoding: UTF-8
class Home
class << self
  # ---------------------------------------------------------------------
  #   Méthodes d'helper pour constuire la page d'accueil
  # ---------------------------------------------------------------------

  def presentation_atelier
    (
      "L’ATELIER ICARE est un <strong>atelier d’écriture en ligne</strong> proposant un accompagnement professionnel de tout projet d’histoire (scénario, roman, BD…) ainsi qu’un ap&shy;pren&shy;tis&shy;sage de la narration et de la dramaturgie, da la simple ini&shy;tia&shy;tion jusqu’au perfectionnement." +
      bouton_presentation_complete
    ).
    in_div(id: 'presentation_atelier')
  end
  def bouton_presentation_complete
    'Présentation complète'.in_a(href: 'overview/home', class: 'btn main block')
  end

  def presentation_phil
    (
      conteneur_medaillon_phil +
      presentation_texte_phil
    ).in_div(id: 'presentation_phil') +
    bouton_modules_dapprentissage
  end

  def bouton_modules_dapprentissage
    (
      (bouton_reussites + bouton_temoignages).in_div(class: 'liens_reussites_temoignages') +
      'Modules d’apprentissage'.in_a(href: 'abs_module/list', class: 'btn main').in_div(id: 'div_btn_modules') +
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

  def conteneur_medaillon_phil
    '<img id="medaillon" src="view/img/atelier/phil-medaillon.png" />'.in_div(id: 'conteneur_medaillon')
  end
  def presentation_texte_phil
    "L'atelier Icare est animé par <strong>Philippe Perret</strong>, scénariste professionnel, romancier (<a href=\"http://livre.fnac.com/a1451727/Philippe-Perret-Mort-vivant\" target='_blank'>mort@vivant</a>, Ed. Anne Carrière), compositeur, musicien et pé&shy;da&shy;go&shy;gue passionné (auteur de <a href=\"http://www.amazon.fr/Savoir-Rédiger-Presenter-Son-Scenario/dp/1090461054\" target=\"_blank\">Savoir rédiger et pré&shy;sen&shy;ter du scénario</a>).".in_div(id: 'presentation_texte')
  end

  def bloc_citation
    hcitation = site.get_a_citation(only_online: true)
    hcitation ||= {citation: "Ici en online la citation", auteur: "Auteur", id: 1}
    (
      (
        image('pictos/apo-open.png', class: 'openapo')  +
        hcitation[:citation]          +
        image('pictos/apo-close.png', class: 'closeapo')
      ).in_div(id: 'texte_citation') +
      (
        'Explicitation'.in_a(href: "http://www.laboiteaoutilsdelauteur.fr/citation/#{hcitation[:id]}/show", target: :new).in_span(class: 'fleft italic') +
        hcitation[:auteur].in_span(class: 'auteur')
        ).in_div(id: 'auteur_citation')
    ).in_div(id: 'citation')
  rescue Exception => e
    debug e
    ''
  end

  # Bloc contenant les dernières activités
  # Soit on lit le listing fabriqué courant, soit on l'actualise
  def bloc_dernieres_activites
    htmlfile = site.file_last_actualites
    # last_actu = dbtable_actualites.select(order: 'created_at DESC', limit: 1).first
    last_actu =
      if dbtable_actualites.exist?
        dbtable_actualites.last_update.to_i
      else
        nil
      end
    dernieres_activites =
      if last_actu.nil?
        'Aucune activité pour le moment.'.in_span(class: 'message').in_li(class: 'actu italic').in_ul(id: 'last_actualites')
      elsif htmlfile.exist? && last_actu < htmlfile.mtime.to_i
        htmlfile.read
      else
        # Il faut actualiser le listing des actualités
        site.require_objet 'actualite'
        SiteHtml::Actualite.listing_accueil
      end
    (
      'Dernières activités'.in_legend +
      dernieres_activites
    ).in_div(id: 'div_last_actualites')
  end

  def separation
    '<div style="clear:both"></div>'+
    '<div class="separation"></div>'
  end

end #/<< self
end #/Home
