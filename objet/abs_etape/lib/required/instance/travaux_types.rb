# encoding: UTF-8
class AbsModule
class AbsEtape

  # Méthode appelée à l'évaluation du travail de la méthode lorsqu'elle
  # fait appel à des travaux-type
  # TODO À IMPLÉMENTER
  def travail_type rubrique, wt_id
    "[FORMATER rubrique : #{rubrique}, wt_id: #{wt_id}]"
  end

  # Retourne la liste des travaux types de l'étape sous
  # forme d'une instance d'ensemble {AbsModules::AbsEtapes::AbsTravauxTypes}
  def travaux_types
    @travaux_types ||= begin
      AbsModule::AbsEtape.require_module 'travaux_types'
      AbsModules::AbsEtapes::AbsTravauxTypes.new(self)
    end
  end

end #/AbsEtape
end #/AbsModule
