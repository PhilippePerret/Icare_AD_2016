# encoding: UTF-8
class Bureau
class Frigo

  attr_reader :owner_id

  def initialize user_id ; @owner_id = user_id end
  # Le propriétaire du frigo
  def owner ; @owner ||= User.new(owner_id) end

end #/Frigo
end #/Bureau

# Le frigo courant
def frigo ; @frigo ||= Bureau::Frigo.new(site.current_route.objet_id) end
