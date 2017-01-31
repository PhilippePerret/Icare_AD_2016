# encoding: UTF-8
=begin

  Pour interrompre un module d'apprentissage.

=end
class Admin
class Users
class << self

  # Mise en pause d'un module d'apprentissage
  #
  # La mise en pause consiste à mettre le premier bit des
  # options de l'icmodule à 2 (le remettre à 1 quand on redémarre)
  #
  def exec_pause_module
    icarien.icmodule || begin
      error "L'icarien#{icarien.f_ne} #{icarien.pseudo} n’a pas de module courant…"
      return false
    end

    imodule = icarien.icmodule

    imodule.start_pause
    @suivi << '- Ajout d’une pause au module'
    @suivi << '- Réglage du bit d’options du module'

    icarien.send_mail(
      subject: 'Mise en pause de votre module d’apprentissage',
      message: <<-HTML
  <p>Bonjour #{icarien.pseudo},</p>
  <p>Je vous informe de la mise en pause du module d’apprentissage que vous suiviez à l’atelier Icare.</p>
      HTML
    )
    @suivi << '- Mail envoyé à l’icarien pour l’informer.'

    flash "Mise en pause du module de #{icarien.pseudo} exécuté avec succès en #{ONLINE ? 'ONLINE' : 'OFFLINE'}."

  end
  # /exec_pause_module
end #/<< self
end #/Users
end #/Admin
