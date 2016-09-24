# encoding: UTF-8
=begin

  Module d'ajout de points d'abonnement

=end


class SiteHtml
  class Cadeau

    # Le message à inscrire
    def output
      if user.identified?
        user.add_jours_abonnement(start_time: Time.now.to_i, nombre_jours: nombre_jours, raison: raison_cadeau)
        "Bravo ! Vous venez d'obtenir #{nombre_jours} jours d'abonnements ! :-)".in_div(class: 'air big')
      else
        'Malheureusement, sans être inscrit, vous ne pouvez obtenir des jours d’abonnements…'.in_div(class: 'air big red')
      end
    end

    # Produit une erreur si l'user n'a pas le droit à ce cadeau
    def available?
      nombre_jours != nil || raise('Désolé, mais vous ne devez recevoir aucun points d’abonnement…')
      session_ok? || raise('Ne seriez-vous pas en train d’essayer de pirater le site ? Si vous continuez, je vous mets en liste noire.')
    end

    def nombre_jours
      @nombre_jours ||= begin
        param(:nombre_points_gratuits)
      end
    end
    def raison_cadeau
      @raison_cadeau ||= param(:raison_points_gratuits)
    end

    def session_ok?
      session_check = param(:session_id_points_gratuits)
      session_check == app.session.session_id
    end

  end
end
# Différents cas :
# - C'est un visiteur quelconque (non inscrit)
# - C'est un simple inscrit
# - C'est un abonné (=> allonger son abonnement)
# - C'est un administrateur

def cadeau
  @cadeau ||= SiteHtml::Cadeau.new
end
