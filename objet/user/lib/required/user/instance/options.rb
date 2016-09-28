# encoding: UTF-8
=begin

  Les bits d'options de 0 à 15 sont réservés à l'administration
  et les bits de 16 à 31 sont réservés à l'application elle-même.

  C'est ici qu'on définit ces options propres à l'application.

=end
class User

  # Bit 16
  # État de l'icarien
  def bit_state
    options[16].to_i
  end

  # Bit 17 et suivant, cf. le fichier
  #  ./ruby/_objets/User/model/Preferences/preferences.rb dans
  # l'atelier Icare_AD
  # En fait, le bit 17 (18e) peut prendre les valeurs :
  #   0: rapport quotidien si actif
  #   1: jamais de mails
  #   2: résumé hebdomadaire
  def pref_mails_activites ; options[17].to_i end # bit 17 (= 18e)

  # Une valeur de 0 à 9 (voir plus) définissant où l'user
  # doit être redirigé après son login. Ces valeurs peuvent être
  # définies par l'application, dans REDIRECTIONS_AFTER_LOGIN
  # dans la fichier site/config
  # avec en clé le nombre du bit 18 :
  #   site.redirections_after_login = {
  #     '1' => {hname: "<nom pour menu>", route: 'route/4/show'},
  #     '2' => etc.
  #   }
  def pref_goto_after_login; options[18].to_i end # bit 18 (= 19e)

  # = Type de contact =
  #   0:  Par mail et par message (frigo)
  #   1:  Par mail seulement
  #   2:  Par message seulement
  #   8:  Aucun contact
  def pref_type_contact; options[19].to_i end

  def pref_cache_header?        ; pref? 3 end # bit 20
  def pref_share_historique?    ; pref? 4 end # bit 21
  def pref_notify_when_message? ; pref? 5 end # bit 22
  def pref_contact_world?       ; pref? 6 end # bit 23

  def pref? relbit
    realbit = 17 + relbit
    options[realbit].to_i == 1
  end

  def bit_reality
    options[24].to_i
  end


end
