# encoding: UTF-8
class Bureau
class Frigo
class Thread

  attr_reader :id

  # +tid+ Identifiant du thread. Nil si c'est un nouveau thread
  def initialize tid
    @id = tid
  end

  # Tous les messages de ce thread. C'est une liste classée
  # d'instance Bureau::Frigo::Thread::Message
  def messages

  end

end #/Thread
end #/Frigo
end #/Bureau
