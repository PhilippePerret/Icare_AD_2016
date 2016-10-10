# encoding: UTF-8
class Cron

  # Exécution de tous les processus CRON à lancer, en fonction
  # de l'heure.
  #
  # Rappel : le cron-job travaille toutes les heures.
  def exec

    run_processus 'mail_activites', :once_a_day

    run_processus 'nettoyage_site', :once_a_day

    run_processus 'echeances',      :once_a_day

  end

  # Méthode appelée en fin de processus de cron, toutes les
  # heures. Elle sert principalement à envoyer le rapport de cron
  # à l'administrateur si c'est nécessaire.
  def stop
    # On envoie le rapport à l'administrateur
    Cron::Message.send_admin_report
  end

  # = MAIN =
  #
  # Méthode principale qui joue le processus.
  #
  # La date de dernière exécution est enregistrée dans la table
  #
  def run_processus proc_name, frequence = :once_a_day
    Processus.new(proc_name).run_if_needed(frequence)
  rescue Exception => e
    bt = e.backtrace.join("\n")
    log "### ERREUR EN EXECUTANT LE PROCESSUS #{proc_name} : #{e.message}\n#{bt}"
  end

  def folder_processus
    @folder_processus ||= SuperFile.new([FOLDER_CRON, 'processus'])
  end

end #/Cron
