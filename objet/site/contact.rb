# encoding: UTF-8
class SiteHtml
  def envoyer
    current_mail.send
  end

  def current_mail
    @current_mail ||= Contact::new
  end

  class Contact

    attr_reader :sent

    # Envoi du message
    def send
      valide? || return
      if site.send_mail data_mail
        @sent = true
      end
    end

    def sent?
      @sent === true
    end
    def valide?
      subject != nil      || raise('Il faut indiquer le sujet de votre message.')
      subject.length >= 5 || raise('Votre sujet est trop court pour être vrai…')
      raise "Il faut indiquer le contenu de votre message." if message.nil?
      raise "Votre message est trop court pour être vrai…" if message.length < 5
      raise "Il faut indiquer votre adresse mail, pour pouvoir recevoir une réponse." if sender.nil?
      raise "La confirmation de votre mail ne correspond pas…" if sender != confirmation_mail
      raise "Il faut répondre à la question anti-robot." if captcha.nil?
      raise "Seriez-vous un robot ?…" if captcha != 366
    rescue Exception => e
      error e.message
    else
      true
    end

    def data_mail
      @data_mail ||= {
        to:       site.mail,
        from:     sender,
        subject:  subject,
        message:  message,
        formated: false
      }
    end

    def subject
      @subject ||= data[:sujet].nil_if_empty
    end

    def message
      @message ||= data[:message].nil_if_empty
    end

    def sender
      @sender ||= data[:mail] || (user.identified? ? user.mail : nil)
    end

    def mail_confirmation
      @mail_confirmation ||= data[:mail_confirmation]
    end
    alias :confirmation_mail :mail_confirmation

    def data
      @data ||= param(:contact) || Hash.new
    end

    def captcha
      @captcha ||= data[:captcha].nil_if_empty.to_i_inn
    end

  end
end
