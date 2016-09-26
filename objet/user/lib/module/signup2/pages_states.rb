# encoding: UTF-8
class Signup
class << self

  def page_form_identite
    if (current_data = get_identite)
      param(user: current_data)
    end
    Signup.view('form_identite.erb')
  end

  def page_form_modules
    if (current_data = get_modules)
      debug "current modules : #{get_modules.inspect}"
    else
      current_data = Array.new
    end
    param(modules_checked: current_data)
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
