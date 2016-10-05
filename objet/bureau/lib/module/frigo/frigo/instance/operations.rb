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

    mail_existe = dbtable_frigo_discussions.count(where:{user_mail: qmail}) > 0
    # Si le pseudo et le captcha ne sont pas remplis,
    # c'est qu'il s'agit d'une identification
    pse = param(:qpseudo).nil_if_empty
    cap = param(:cachcapvalue).nil_if_empty
    pour_identification = (pse.nil? && cap.nil?) || mail_existe

    if pour_identification
      has_discussion_with_current? || begin
        raise('Impossible de vous reconnaitre avec le mail et le code secret indiqués.')
      end
    else
      qpassword.length > 5 || begin
        param(qpassword: nil)
        raise('Le code doit faire au moins 6 caractères.')
      end
      app.captcha_valid? || begin
        raise('Le captcha n’est pas bon. Seriez-vous un robot ?…')
      end
      create_discussion
    end
    # En se rechargeant, la page fera appel à `frigo.current_discussion`
    # qui affichera la discussion courante avec un formulaire pour la
    # poursuivre
  rescue Exception => e
    debug e
    error e
  end
  # /create_of_retreive_discussion


end
