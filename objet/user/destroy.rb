# encoding: UTF-8
# require 'sqlite3'

class User

  RAISONS_DESTROY = [
    "Je n'ai plus le temps d'écrire",
    "Je n'ai plus rien à apprendre du BOA",
    "Ce site ne me plait pas du tout",
    "J'ai renoncé à l'écriture"
  ]

  # Procédure complète de destruction du compte de l'user
  # Note : Elle ne s'appelle pas `destroy` car elle serait directement
  # appelée par la route.
  def exec_destroy
    raise "Pirate !" if (self.id != site.current_route.objet_id) && !user.manitou?
    dkill[:confirmation_destroy] == '1' || raise( "Opération impossible." )
    self.id != 1 || raise( "Impossible de détruire Phil" )
    self.id != 3 || raise( "Impossible de détruire Marion" )

    # On conserve les données simplement pour la rédaction
    # des messages.
    @data_killed = {
      pseudo: self.pseudo.freeze,
      id:     self.id.freeze
    }

    # === DESTRUCTION ===
    proceed_destruction

    flash "Vous avez été détruit avec succès, #{@data_killed[:pseudo]}. Au regret de vous voir partir…"
    redirect_to :home
  rescue Exception => e
    debug e
    error e.message
    return false
  else
    return true
  end

  # Méthode qui procède vraiment à toutes les opérations
  # de destruction de l'auteur.
  def proceed_destruction
    destroy_messages_forum
    destroy_programmes_unan
    deconnecte_user unless user.admin?
    remove # méthode générale qui détruit le dossier et la donnée dans la base
  end

  def dkill
    @dkill ||= param(:destroy) || Hash.new
  end

  def deconnecte_user
    debug "  * Déconnexion de l'user courant"
    deconnexion
    debug "  = User déconnecté"
  end

  # Destruction de l'user
  # (en fait, on le marque simplement détruit)
  # Ça détruit également son dossier de data s'il en a
  # un dans l'application
  def destroy_in_database_users
    debug "  * Destruction de l'user dans la base de données"
    self.remove
    debug "  = User détruit dans la base de données"
  end

  # Destruction des messages forum
  # (en fait, on marque que l'user a supprimé son compte mais on
  #  garde le message)
  def destroy_messages_forum
    error "La procédure de suppression des messages d'un user détruit est complètement à réimplémenter (#{__FILE__}:#{__LINE__})" if OFFLINE
    return
    debug "  = Messages forum détruits"
  end

  # Destruction des programmes UN AN
  def destroy_programmes_unan
    debug "  * Destruction des programmes & projets UAUS"
    # On charge tout ce qui concerne Unan, on en aura
    # besoin plus bas (pour les bases de données)
    site.require_objet 'unan'
    # Destruction des paiements "1UN1SCRIPT" de l'self
    where = "user_id = #{self.id} AND objet_id = '1AN1SCRIPT'"
    nombre_paiements = User.table_paiements.count(where:where)
    User.table_paiements.delete(where:where)

    # Destruction de son dossier dans database/data/unan/user
    with_dossier_db = self.folder_data.exist? ? "détruit" : "inexistant"
    self.folder_data.remove if self.folder_data.exist?

    # Destruction de ses programmes dans la table
    where = "auteur_id = #{self.id} AND options LIKE '1%'"
    data_program = Unan::table_programs.get(where: where)

    # Modification des options
    opts = data_program[:options]
    opts[0] = '0' # bit inactif
    opts[2] = '1' # bit abandon
    Unan.table_programs.update( data_program[:id], { options: opts } )

    # Note : on ne touche pas au projet.

    debug "  = Arrêt du dernier programme UAUS OK"
  end


  # ---------------------------------------------------------------------
  #   Helper méthodes
  # ---------------------------------------------------------------------

  def self.menu_raison_supp_compte
    RAISONS_DESTROY.each_with_index.collect do |raison, iraison|
      raison.in_option(value: iraison)
    end.join('').in_select(name:'destroy[raison]', id:'destroy_raison')
  end
end

if param(:operation) == 'destroy_compte'
  # Pour qu'un administrateur puisse aussi détruire un user par
  # le biais de cette méthode, il ne faut pas prendre l'user
  # courant mais l'user défini dans la route.
  #
  # Une protection sérieuse est faite pour empêcher n'importe
  # qui de procéder à l'opération.
  User.get(site.current_route.objet_id).exec_destroy
end
