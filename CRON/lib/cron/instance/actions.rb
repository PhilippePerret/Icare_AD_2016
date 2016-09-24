# encoding: UTF-8
class Cron

  def exec
    run_processus 'mail_activites'
  end

  def stop
    # On envoie le rapport à l'administrateur
    Cron::Message.send_admin_report
  end

  def run_processus proc_name
    folder = folder_processus + proc_name
    folder.require
    send("_#{proc}".to_sym)
  end

  def folder_processus
    @folder_processus ||= SuperFile.new([FOLDER_CRON, 'processus'])
  end
end
