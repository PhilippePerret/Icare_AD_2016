# encoding: UTF-8
=begin

  Méthodes d'helper pour le header de la page

=end
class SiteHtml
class Header
class << self

  def sign_buttons
    if user.identified?
      signout_button
    else
      signin_button + signup_button
    end.in_div(id: 'signinupout_buttons')
  end

  def signout_button
    'Déconnexion'.in_a(href:"user/#{user.id}/deconnexion", class: 'btn')
  end
  def signin_button
    site.route?('user/signin') && (return '')
    'S\'identifier'.in_a(href:'user/signin', class: 'btn', back_to: route_courante)
  end
  def signup_button
    (site.route?('user/signup') || site.route?('user/signup2')) && (return '')
    'Poser&nbsp;sa&nbsp;candidature'.in_a(href: 'user/signup', id: 'btn_signin', class: 'btn main')
  end

end #/<< self
end #/Header
end #/SiteHtml
