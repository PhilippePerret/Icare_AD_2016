# encoding: UTF-8
class Frigo
class Discussion
class Message
class << self

  # Retourne le formulaire pour laisser un message sur le frigo
  # de l'icarien
  def form_message premier = true
    (
      inner_form(premier)
    ).in_div(class: 'boite_new_message')
  end

  def inner_form premier
    mess_destinataire =
      if frigo.owner?
        frigo.current_discussion.interlocuteur_designation
      else
        frigo.owner.pseudo
      end
    mess_destinataire = "#{premier ? 'Premier message' : 'Nouveau message'} pour #{mess_destinataire}"
    (
      'save_message_frigo'.in_hidden(name:'operation') +
      app.checkform_hidden_field('form_new_message') +
      frigo.current_discussion.id.in_hidden(name: 'frigo_discussion_id', id: 'frigo_discussion_id') +
      param(:qmail).in_hidden(name:'qmail', id: 'frigo_mail') +
          # Noter que param(:qmail) peut ne pas être défini, lorsque par exemple
          # c'est le propriétaire qui visite son frigo.
      ''.in_textarea(name:'frigo_message', id: 'frigo_message', placeholder: mess_destinataire, style: 'height:100px!important;width:94%;padding:1em') +
      'Déposer sur le frigo'.in_submit(class: 'btn small').in_div(class: 'buttons') +
      'Styles utilisables : **texte en gras** (<strong>texte en gras</strong>), *texte en italique* (<em>texte en italique</em>), _texte souligné_ (<u>texte souligné</u>)'.in_p(class: 'tiny')
    ).in_form(id: "form_new_message", action: "bureau/#{frigo.owner_id}/frigo")
  end

end #<< self
end #/Message
end #/Discussion
end #/Frigo
