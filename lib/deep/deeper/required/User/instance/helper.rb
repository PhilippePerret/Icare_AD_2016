# encoding: UTF-8
class User

  # Cette méthode peut être surclassée dans
  # ./lib/app/required/user/helper.rb
  def htype
    "utilisa#{f_trice}" +
    ' ' +
    case true
    when subscribed? then 'abonné' + f_e
    when identified? then 'identifié' + f_e
    end
  end

end #/User
