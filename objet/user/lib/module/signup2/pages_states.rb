# encoding: UTF-8
class Signup
class << self

  def page_form_identite
    if (current_data = get_identite)
      flash "J'ai pu récupérer les données de l'identité"
      debug "current data identité : #{current_data.inspect}"
      param(user: current_data)
    end
    Signup.view('form_identite.erb')
  end

  def page_form_modules
    Signup.view('form_modules.erb')
  end
  def page_form_documents
    Signup.view('form_documents.erb')
  end

  def page_confirmation
    Signup.view('page_confirmation.erb')
  end

end #/<< self
end #/ Signup
