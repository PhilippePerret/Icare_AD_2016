# encoding: UTF-8
class Icarien
  extend MethodesMainObjet
  class << self

    def table
      @table ||= site.dbm_table(:users, 'users')
    end

    def titre
      @titre ||= 'Icarien'
    end

    def data_onglets
      {
        "Liste" => 'icarien/list'
      }
    end
    
  end #/<< self
end #/Icarien
