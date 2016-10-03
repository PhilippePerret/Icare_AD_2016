# encoding: UTF-8
class Frigo
class << self

  def current
    @current ||= begin
      Bureau::Frigo.new(site.current_route.objet_id)
    end
  end
end #/<< self
end #/Frigo
