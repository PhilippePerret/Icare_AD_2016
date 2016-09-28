# encoding: UTF-8
class Cron
class Message
class << self

  # Pour consigner un message
  def log str, options = nil
    @logs ||= Array.new
    @logs << {content: str, options: (options || Hash.new)}
  end

  def send_admin_report
    send_mail_to_admin(
      subject:    "Un rapport de fin - #{Time.now}",
      message:    self.admin_report,
      formated:   true,
      no_header:  true
    )
  end

  # Construction du rapport administrateur
  def admin_report
    messages_log =
      if @logs.nil? || @logs.empty?
        'Aucun message log'.in_div
      else
        @logs.collect{|h| h[:content].in_div(class: h[:options][:class])}.join
      end
    <<-TXT
#{messages_log}
<p>Une dernière citation sera : #{site.get_a_citation(no_last_sent: true).inspect}</p>
<h2>Messages logs</h2>
    TXT
  end

end #/<< self
end #/Message
end #/Cron
