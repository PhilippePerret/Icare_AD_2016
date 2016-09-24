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
  def pref_bureau_after_login?  ; pref? 0 end # bit 17 (= 18e)
  def pref_mail_actualites?     ; pref? 1 end # bit 18 envoi annonces
  def pref_contact_icarien?     ; pref? 2 end # bit 19 contacté par autre user
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
