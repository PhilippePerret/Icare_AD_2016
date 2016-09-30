class Bureau
class Frigo

  attr_reader :owner_id

  def initialize user_id
    @owner_id = user_id
  end
  def owner
    @owner ||= User.new(owner_id)
  end

end #/Frigo
end #/Bureau

def frigo
  @frigo ||= Bureau::Frigo.new(site.current_route.objet_id)
end
