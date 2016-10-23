# encoding: UTF-8
class Cron
class Message
class << self

  # Pour récupérer le contenu du log, pour les tests
  attr_reader :logs

  # Pour consigner un message
  def log str, options = nil
    @logs ||= Array.new
    @logs << {content: str, options: (options || Hash.new)}
  end

  # Envoi du message à l'administrateur, mais seulement s'il y a des
  # choses à dire.
  def send_admin_report
    return if @logs == nil || @logs.count == 0
    send_mail_to_admin(
      subject:    "Un rapport de fin - #{Time.now}",
      message:    self.admin_report,
      formated:   true,
      no_header:  true
    )
  end

  # Construction du rapport administrateur
  def admin_report
    messages_log = @logs.collect{|h| h[:content].in_div(class: h[:options][:class])}.join
    <<-TXT
<h2>Messages logs</h2>
#{messages_log}
    TXT
  end

end #/<< self
end #/Message
end #/Cron
