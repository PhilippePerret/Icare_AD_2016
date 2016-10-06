# encoding: UTF-8
class Admin
class Overview
class << self

  # = main =
  #
  # Méthode principale affichant l'aperçu de tous les icariens
  # en activité
  #
  def display
    drequest = {
      where:    'SUBSTRING(options,17,1) = "2"',
      colonnes: []
    }
    dbtable_users.select(drequest).collect do |huser|
      User.new(huser[:id]).overview
    end.join.in_div(class: 'users_overview')
  end

end #/<< self
end #/Overview
end #/Admin
