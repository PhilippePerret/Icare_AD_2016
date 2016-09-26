# encoding: UTF-8
class Signup
class << self

  # Bandeau, au-dessus de la page d'inscription, indiquant
  # où l'on en est.
  def bandeau_states
    {
      'identite'      => {hname: 'Votre<br>identité'},
      'modules'       => {hname: 'Choix du<br>module'},
      'documents'     => {hname: 'Documents de présentation'},
      'confirmation'  => {hname: 'Confirmation inscription'}
    }.collect do |idstate, dstate|
      selected = (state == idstate) ? 'selected' : nil
      if state_done?(idstate)
        href = "#{site.current_route.route}?signup[state]=#{idstate}"
        dstate[:hname].in_a(href: href)
      else
        dstate[:hname]
      end.in_div(class: "state #{selected}".strip)
    end.join.in_div(id: 'bandeau_states')
  end

  # Chargement de la vue (dans le dossier signup2/view/)
  def view relpath
    (folder_views + relpath).deserb(self)
  end

  def liste_modules_checkboxable
    site.require_objet('abs_module')
    cbs_modules = ''
    AbsModule.each_instance(order: 'tarif ASC') do |amod|
      href    = "abs_module/#{amod.id}/show"
      cb_name = "modules[#{amod.id}]"
      cb_id   = "modules-#{amod.id}"
      mod_detail  = 'Détail'.in_a(href: href, class: 'small', target: :new).in_span(class: 'link')
      mod_name    = amod.name.in_span(class: 'name')
      mod_tarif   = "#{amod.tarif} €#{amod.type_suivi? ? ' / mois' : ''}".in_span(class: 'tarif')
      mod_libelle = "#{mod_detail}#{mod_name} #{mod_tarif}"
      mod_libelle = mod_libelle.in_checkbox(name: cb_name, id: cb_id)
      cbs_modules << mod_libelle.in_li(class: 'absmodule', id: "absmodule-#{amod.id}")
    end
    # /fin boucle sur toutes les instances modules
    cbs_modules = cbs_modules.in_ul(id:'abs_modules')
    return cbs_modules
  end

end #/ << self
end #/ Signup
