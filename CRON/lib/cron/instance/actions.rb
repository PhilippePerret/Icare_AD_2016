# encoding: UTF-8
class Cron

  # Exécution de tous les processus CRON à lancer, en fonction
  # de l'heure.
  #
  # Rappel : le cron-job travaille toutes les heures.
  def exec
    # Le mail d'activité ne doit être envoyé qu'une fois par
    # jour à 2 heures du matin.
    # TODO POUR LE MOMENT, ON LE FAIT CHAQUE FOIS
    run_processus 'mail_activites' # if deux_heures_du_matin?
  end

  def deux_heures_du_matin?
    Time.now.hour == 2
  end

  # Méthode appelée en fin de processus de cron, toutes les
  # heures. Elle sert principalement à envoyer le rapport de cron
  # à l'administrateur si c'est nécessaire.
  def stop
    # On envoie le rapport à l'administrateur
    Cron::Message.send_admin_report
  end

  def run_processus proc_name
    folder = folder_processus + proc_name
    folder.require
    send("_#{proc_name}".to_sym)
  end

  def folder_processus
    @folder_processus ||= SuperFile.new([FOLDER_CRON, 'processus'])
  end
end
