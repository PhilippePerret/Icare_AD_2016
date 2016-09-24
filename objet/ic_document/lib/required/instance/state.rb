# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # Dans ces trois méthodes d'état, +ty+ doit être
  # :original ou :comments
  def shared?     ty ; has?(ty) && acces(ty) == 1 end
  def has?        ty ; options[ty == :original ? 0 : 8].to_i == 1   end
  def downloaded? ty ; options[ty == :original ? 2 : 10].to_i == 1  end
  def complete?   ty ; options[ty == :original ? 5 : 13].to_i == 1  end

end #/IcDocument
end #/IcEtape
end #/IcModule
