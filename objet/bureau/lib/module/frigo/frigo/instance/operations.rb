# encoding: UTF-8
class Frigo

  def create_of_retreive_discussion
    qmail     = param(:qmail).nil_if_empty
    qmail != nil || begin
      param(qmail: nil)
      raise('Il faut indiquer votre mail.')
    end
    qpassword = param(:qpassword).nil_if_empty
    qpassword != nil || begin
      param(qpassword: nil)
      raise('Il faut fournir un mot de passe.')
    end
    qpassword.length > 5 || begin
      param(qpassword: nil)
      raise('Le code doit faire au moins 6 caractères.')
    end
    app.captcha_valid? || begin
      raise('Le captcha n’est pas bon. Seriez-vous un robot ?…')
    end
    has_discussion_with_current? || create_discussion
    # En se rechargeant, la page fera appel à `frigo.current_discussion`
    # qui affichera la discussion courante avec un formulaire pour la
    # poursuivre
  rescue Exception => e
    debug e
    error e
  end
  # /create_of_retreive_discussion


end
