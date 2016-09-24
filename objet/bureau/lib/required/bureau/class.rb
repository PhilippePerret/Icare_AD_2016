# encoding: UTF-8
class Bureau

  extend MethodesMainObjet

  class << self
    def titre
      @titre ||= 'Votre bureau'.freeze
    end

    def data_onglets
      dgs = Hash.new
      if user.recu? || user.admin?
        dgs.merge!(
        'Bureau'     => 'bureau/home',
        'Historique' => 'bureau/historique',
        'Outils'     => 'bureau/outils'
        )
        unless user.admin?
          dgs.merge!('Documents' => 'quai_des_docs/list')
        end
        if user.actif? || user.en_pause?
          dgs.merge!('Votre travail' => 'bureau/home#section_travail_auteur')
        end
      end
      return dgs
    end
  end #/<< self

end
