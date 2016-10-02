# encoding: UTF-8
class Bureau
class Frigo
class Thread
class Message

  attr_reader :id

  # +mid+ Identifiant du message
  def initialize mid = nil
    @id = mid
  end

end #/Message
end #/Thread
end #/Frigo
end #/Bureau
