# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # Pour obtenir un texte du type :
  # "document “mon beau document” de Lauteur (étape 10 du module suivi)"
  #
  def designation
    s = "document “#{original_name}”"
    owner.id == user.id || s << " de #{owner.pseudo}"
    if icmodule_id != nil && icetape_id != nil
      s << " (étape #{icetape.numero} du module “#{icmodule.abs_module.name}”)"
    end
    return s
  end

end #/IcDocument
end #/IcEtape
end #/IcModule
