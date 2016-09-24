# encoding: UTF-8

class User

  # Redirection après l'identification
  #
  # Noter un point important : si un `back_to` a été utilisé pour
  # se rendre à une adresse après l'identification, cette méthode
  # ne sera jamais appelée. Donc il ne faut l'utiliser que pour
  # une redirection et rien d'autre.
  #
  # La redirection peut avoir été déterminée par les préférences
  # grâce à la préférence 'goto'
  def redirect_after_login
    if (goto = preference(:goto_after_login))
      route =
        case goto
        when '0'  # Le profil
          "user/#{id}/profil"
        when '1'  # Dernière page consultée
          # La dernière page consultée (ou l'accueil si aucune
          # dernière page consultée n'a été trouvée)
          # C'est dans les connexions qu'on trouve cette information
          res = site.dbm_table(:hot,'connexions').get(id)
          res.nil? ? 'site/home' : res[:route]
        else
          User::GOTOS_AFTER_LOGIN[goto][:route]
        end
      redirect_to route
    else
      # Sinon, on redirige (donc par défaut) vers son bureau
      redirect_to 'bureau/home'
      # debug "[User#redirect_after_login] Aucune redirection"
    end
  end


  # Retourne la valeur d'une préférence, qui peut avoir n'importe
  # quel type puisque c'est une “variable” enregistrée dans la
  # table `variable`
  # Note : Les préférences sont toutes fausses par défaut.
  def preference pref_id, default_value = false
    get_var("pref_#{pref_id}", default_value)
  end

end
