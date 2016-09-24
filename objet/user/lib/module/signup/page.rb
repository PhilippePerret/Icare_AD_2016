# encoding: UTF-8
=begin
Extension de la class Page (singleton) lorsque la route `user/signup` est
invoquée
=end
class Page

  # Retourne soit le formulaire par défaut soit le
  # formulaire défini par le développeur pour cette
  # application
  def user_signup_form
    if custom_signup_form.exist?
      custom_signup_form.deserb( user )
    else
      normal_signup_form.deserb( user )
    end
  end

  def custom_signup_form
    @custom_signup_form ||= (site.folder_objet + 'user/signup_form.erb')
  end

  def normal_signup_form
    @normal_signup_form ||= (site.folder_objet + 'user/lib/module/signup/form.erb')
  end
end
