# encoding: UTF-8
=begin

  Module gérant le profil d'un inscrit ou d'un abonné.
  Il permet notamment de rediriger vers l'identification
  si l'user n'est pas identifié.

=end
unless user.identified?
  redirect_to 'user/signin'
end


class User

end #/User

case param(:operation)

when 'save_preferences'
  # Enregistrement des préférences de l'utilisateur
  #
  # Noter que pour les checkbox, il faut absolument en lister
  # les clés ci-dessous pour que les changements soient pris en
  # compte. Dans le cas contraire, si une checkbox a été
  # préalablement cochée, sa valeur sera à 'on' mais ne sera
  # pas modifiée si la case est décochée puisqu'elle n'apparaitra
  # pas dans la table prefs ci-dessous.
  #
  # On produit une erreur si l'user qui passe par ici n'est pas
  # l'user possesseur des préférences ou un administrateur
  raise_unless (user.id == site.current_route.objet_id) || user.admin?

  prefs = param(:prefs)

  # On met à nil les valeurs des checkbox qui ne sont pas
  # cochées (cf. l'explication ci-dessus)
  [].each do |k|
    next if prefs.key?(k)
    prefs[k] = nil
  end

  # Cas spécial de la donnée :
  # Il faut régler :bureau_after_login en conséquence
  prefs.merge!(bureau_after_login: prefs[:goto_after_login] == '2')

  user.set_preferences prefs
  flash "#{user.pseudo}, vos préférences sont enregistrées."
end

def menu_mail_updates
  [
    ['daily',   'chaque jour'],
    ['weekly',  'une fois par semaine'],
    ['never',   'jamais']
  ].in_select(name:'prefs[mail_updates]', id: 'prefs_mail_updates', class: 'inline', selected: user.preference(:mail_updates))
end
def menu_goto_after_signin
  liste_goto_after_signin.in_select(name:'prefs[goto_after_login]', id: 'prefs_goto_after_login', class: 'inline', selected: user.preference(:goto_after_login).to_s)
end
# Liste des redirections possibles après le login
def liste_goto_after_signin
  @liste_goto_after_signin ||= begin
    User::GOTOS_AFTER_LOGIN.collect do |k, dk|
      next nil if dk[:admin] && !user.admin?
      [k, dk[:hname]]
    end.compact
  end
end
