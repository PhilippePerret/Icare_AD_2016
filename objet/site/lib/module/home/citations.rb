# encoding: UTF-8
class Home
class << self

  def bloc_citation
    hcitation = site.get_a_citation(only_online: true)
    hcitation ||= {citation: "Ici en online la citation", auteur: "Auteur", id: 1}
    (
      (
        'Au hasard des citations…'.in_div(class: 'italic discret',style: 'margin-bottom:0.5em') +
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

end #/<< self
end #/Home
