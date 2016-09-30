# encoding: UTF-8
class Bureau

  extend MethodesMainObjet

  NO_INSTANCIATION_BY_URL = true

  class << self
    def titre
      @titre ||= 'Votre bureau'.freeze
    end

    def data_onglets
      dgs = Hash.new
      if( user.recu? && user.owner?)# || user.admin?
        dgs.merge!(
        'Bureau'     => 'bureau/home',
        'Historique' => 'bureau/historique',
        'Outils'     => 'bureau/outils',
        'Frigo'      => "bureau/#{user.id}/frigo"
        )
        unless user.admin?
          dgs.merge!('Documents' => 'bureau/documents')
        end
        if user.actif? || user.en_pause?
          dgs.merge!('Votre travail' => 'bureau/home#section_travail_auteur')
        end
      end
      return dgs
    end
  end #/<< self

end

class User
  def owner?
    site.current_route.objet_id.nil? || user.id == site.current_route.objet_id
  end
end
