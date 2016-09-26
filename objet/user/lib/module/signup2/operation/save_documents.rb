# encoding: UTF-8
class Signup
class << self

  # Méthode qui sauve les données d'identité dans un fichier marshal
  # provisoire avant de passer à la suite de l'inscription
  def save_documents
    data_valides? || (return false)
  end


end #/<< self
end #/ Signup
