# encoding: UTF-8
class SiteHtml

  def get_a_citation
    client = client_boa('boite-a-outils_cold') # ensuite : _biblio
    # client = client_boa('boite-a-outils_biblio') # ensuite : _biblio
    candidates = client.query("SELECT id, citation, auteur FROM citations ORDER BY last_sent ASC LIMIT 10 OFFSET 11;")
    candidates = candidates.collect{|row| row}
    candidates.shuffle.shuffle.first
  end

  # Le client ruby qui permet d'intergagir avec la base de
  # données.
  def client_boa db_boa_name
    @client ||= begin
      Mysql2::Client.new(client_data_boa.merge(database: db_boa_name))
    end
  end
  def client_data_boa
    data_mysql_boa[ONLINE ? :online : :offline]
  end
  def data_mysql_boa
    @data_mysql_boa ||= begin
      require './data/secret/mysql_boa'
      DATA_MYSQL_BOA
    end
  end

end
