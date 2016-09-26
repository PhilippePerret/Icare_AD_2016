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
      div_class = ['state']
      selected = (state == idstate)
      selected && div_class << 'selected'
      div =
        if state_done?(idstate)
          href = "#{site.current_route.route}?signup[state]=#{idstate}"
          selected || div_class << 'done'
          dstate[:hname].in_a(href: href)
        else
          dstate[:hname]
        end
      div.in_div( class: div_class.join(' ') )
    end.join.in_div(id: 'bandeau_states')
  end

  # Chargement de la vue (dans le dossier signup/view/)
  def view relpath
    (folder_views + relpath).deserb(self)
  end

end #/ << self
end #/ Signup
