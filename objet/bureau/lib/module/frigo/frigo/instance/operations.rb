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
    # Si la discussion n'existe pas, on la créé
    hdiscussion = has_discussion_with_current?
    if hdiscussion == nil
      # Création de la discussion
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
