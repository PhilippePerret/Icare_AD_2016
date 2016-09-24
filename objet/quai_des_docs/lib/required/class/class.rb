class QuaiDesDocs

  extend MethodesMainObjet

  class << self

    def titre
      "Quai des docs"
    end

    def data_onglets
      {}
    end

    def table_lectures
      @table_lectures ||= site.dbm_table(:modules, 'lectures_qdd')
    end

  end #/<< self

end #/QuaiDesDocs
