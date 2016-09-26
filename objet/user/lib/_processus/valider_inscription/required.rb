# encoding: UTF-8
=begin

  Toutes les méthodes requises pour la validation de l'inscription

=end
def data_modules
  @data_modules ||= Marshal.load(path_data_modules.read)
end
def data_documents
  @data_documents ||= Marshal.load(path_data_documents.read)
end
def path_data_modules
  @path_data_modules ||= folder_signup + 'modules.msh'
end
def path_data_documents
  @path_data_documents ||= folder_signup + 'documents.msh'
end

# Le dossier contenant les données de l'inscription
def folder_signup
  @folder_signup ||= site.folder_tmp + "signup/#{data}"
end
