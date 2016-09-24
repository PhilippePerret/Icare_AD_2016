# encoding: UTF-8
class User
  VARIABLES_TYPES = [String, Fixnum, Bignum, Float, Hash, Array, NilClass]

  # Grade d'un utilisateur par rapport au forum
  # Ces valeurs correspondent au bit 1 (donc le deuxième) des options de l'user.
  GRADES = {
    # Note par rapport aux privilèges forum : ils sont additionnés, donc
    # par exemple le privilège du 3 reprend toujours les privilèges des
    # 0, 1 et 2
    # Si la description commence par "!!!", elle ne sera ajoutée que pour
    # ce grade.
    0 => {hname:'Padawan de l’écriture',                  privilege_forum:'!!!lire les posts publics'},
    1 => {hname:'Simple audi<%= user.f_trice %>',         privilege_forum:'lire tous les posts'},
    2 => {hname:'Audi<%= user.f_trice %> patient',        privilege_forum:'noter les posts'},
    3 => {hname:'Apprenti<%= user.f_e %> surveillé<%= user.f_e %>',     privilege_forum:'!!!écrire des réponses qui seront modérées'},
    4 => {hname:'Simple rédac<%= user.f_trice %>',        privilege_forum:'répondre librement aux posts'},
    5 => {hname:'Rédac<%= user.f_trice %>',               privilege_forum:'initier un sujet'},
    6 => {hname:'Rédac<%= user.f_trice %> émérite',       privilege_forum:'supprimer des messages'},
    7 => {hname:'Rédac<%= user.f_trice %> confirmé<%= user.f_e %>',     privilege_forum:'clore un sujet'},
    8 => {hname:'Maitre rédac<%= user.f_trice %>',       privilege_forum:'supprimer des sujets'},
    9 => {hname:'Expert<%= user.f_e %> d’écriture',      privilege_forum:'bannir des utilisateurs'}
  } unless defined?(GRADES) # quand tests, car on reload ce module


  # Les redirections possibles après l'identification
  # La clé est la valeur enregistrées dans les préférences
  # de l'user (<user>.preference :goto_after_login)
  GOTOS_AFTER_LOGIN = {
    '0' => { hname: 'votre profil', route: nil },
    '1' => { hname: 'votre dernière page consultée', route: nil},
    '3' => { hname: 'l’accueil du site', route: 'site/home'},
    '8' => { hname: 'le dashboard administration', route: 'admin/dashboard', admin: true},
    '9' => { hname: 'la console', route: 'admin/console', admin: true}
  }
end
