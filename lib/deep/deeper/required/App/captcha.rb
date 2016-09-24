# encoding: UTF-8
=begin
  Méthode pour l'utilisation d'un captcha (dynamique, car si statique,
  il suffit de tester la valeur)

  @usage

    Définir dans la configuration (site/config.rb) :

        site.captcha_question = "<la question>"
        site.captcha_value = <la valeur quelconque attendue>

    Dans le formulaire, mettre un champ captcha (de nom indifférent)
    Ajouter aussi : <%= app.hidden_field_captcha_value %>

    Au moment du test du formulaire, utiliser :

        app.captcha_valid?(<valeur fournie par l'user>)

    … pour tester la bonne valeur.
=end
class App
  # Utiliser app.captcha_valid? pour vérifier la valeur fourni par
  # l'utilisateur.
  def hidden_field_captcha_value
    require 'digest/md5'
    # debug "= CAPTCHA GÉNÉRATION = "
    # debug "= app.session.session_id = #{app.session.session_id}"
    # debug "= site.captcha_value = #{site.captcha_value}"
    v = Digest::MD5::hexdigest("#{app.session.session_id}#{site.captcha_value}")
    # debug "= cachcapvalue : #{v}"
    # debug "======================="
    "<input type='hidden' name='cachcapvalue' id='cachcapvalue' value='#{v}' />"
  end

  # Méthode qui retourne TRUE si le captcha est valide
  #
  # @usage      app.captcha_valid?(valeur_fournie)
  #
  # Pour pouvoir fonctionner on doit placer dans le formulaire un
  # champ hidden contenant la valeur cachcapvalue. On peut obtenir le
  # code HTML de ce champ par : app.hidden_field_captcha_value
  #
  def captcha_valid? captcha
    require 'digest/md5'
    # debug "= CAPTCHA VÉRIFICATION ="
    # debug "= app.session.session_id : #{app.session.session_id}"
    # debug "= Captcha fourni : #{captcha}"
    # debug "= param(:cachcapvalue) : #{param(:cachcapvalue)}"
    # debug "========================"
    param(:cachcapvalue) == Digest::MD5::hexdigest("#{app.session.session_id}#{captcha}")
  end

end #/App
