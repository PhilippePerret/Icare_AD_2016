# encoding: UTF-8
class Admin
class Mailing
class << self
  # Opération d'envoi véritable du message
  #
  def exec_mailing_send
    @template_formated = param(:template_formated).nil_if_empty
    @template_formated != nil || (raise "Le message template n'est pas défini.")
    @subject = param(:mail_subject).nil_if_empty
    subject != nil || (raise "Le sujet du mail n'est pas défini.")
    @keys_destinataires = param(:keys_destinataires)
    @keys_destinataires.to_s != "" || (raise "Les clés des destinataires ne sont pas fournis…")
    @keys_destinataires = @keys_destinataires.split(':').collect{|e| e.to_sym}

    rapport = Array.new
    destinataires.each do |u|
      begin
        # ==============================
        # ===== ENVOI DU MESSAGE =======
        # ==============================
        send_message_to u
        rapport << "Message envoyé à #{u.pseudo} (#{u.mail})".in_div
      rescue Exception => e
        rapport << "# ERREUR : Impossible d'envoyer le message à #{u.mail} : #{e.message}".in_span(class: 'warning')
      end
    end

    begin
      send_message_to admin, (forcer = true)
      rapport << "Message envoyé en réel à Phil".in_div
    rescue Exception => e
      error "Impossible d'envoyer le message à l'administrateur."
      rapport << "# IMPOSSIBLE d'envoyer le message à l'administrateur."
    end

    self.content = ("Rapport de mailing".in_div(class: 'bold big air') + rapport.join('')).in_div(id: "rapport_mailing", class: 'cadre small')
  end
  # /opération exec_mailing_send

  # Procède à l'envoi du message
  #
  # +u+ L'user
  def send_message_to u, forcer_offline = false
    u.instance_of?(User) || (raise ArgumentError, "Il faut fournir un User en premier argument.")
    data_mail = {
      subject:  subject,
      message:  real_message_for(u)
    }
    if OFFLINE && (forcer_offline || OPTIONS[:force_offline][:value] === true)
      data_mail.merge! force_offline: true
    end

    # POUR LE MOMENT, JE METS UNE BARRIÈRE DE PROTECTION
    #
    data_mail.delete(:force_offline) if u.mail != admin.mail
    # debug "data mail : #{data_mail.inspect}"

    u.send_mail data_mail
  end

  # Retourne le message réel pour l'icarien de donnée +udata+
  #
  # +u+ Instance {User} de l'icarien à qui il faut envoyer le message
  def real_message_for u
    u.instance_of?(User) || (raise "Le premier paramètre de `real_meassage_for` devrait être un User… Le paramètre est de type #{u.class}")
    data_replacement = {}

    # Seulement si on ne demande pas de laisser les %
    unless OPTIONS[:no_template][:value]
      variables_template.each do |key, dkey|
        value =
          if dkey[:replace].nil?
            u.send(key)
          else
            dkey[:replace]
          end
        data_replacement.merge! key => value
      end
      data_replacement[:pseudo] = data_replacement[:pseudo].capitalize
      # template_formated % data_replacement
      template_formated.gsub(/%\{(.*?)\}/){
        tout = $&
        balise = "#{$1}".to_sym
        if data_replacement.key? balise
          data_replacement[balise]
        else
          tout
        end
      }
    else
      template_formated.gsub(/%\{pseudo\}/, u.pseudo.capitalize)
    end
  end


end #/<< self
end #/Mailing
end #/Admin
