# encoding: UTF-8
class Frigo
class Discussion
class Message

  attr_reader :id

  # +mid+ Identifiant du message
  def as_li
    (
      (
        auteur_humain.in_span(class: 'auteur') +
        date_humaine.in_span(class: 'date')
      ).in_div(class: 'infos') +
      content.in_span(class: 'content')
    ).in_li(class: "mess cote#{auteur_ref}", id: "mess_#{id}")
  end


  def auteur_humain
    if auteur_ref == 'o'
      if frigo.owner?
        'Vous'
      else
        frigo.owner.pseudo
      end
    else
      if frigo.owner?
        discussion.interlocuteur_designation
      else
        'Vous'
      end
    end
  end

  def date_humaine
    created_at.as_human_date(true, true, nil, 'à')
  end

end #/Message
end #/Discussion
end #/Frigo
