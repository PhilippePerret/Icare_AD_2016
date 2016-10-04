# encoding: UTF-8
class Frigo
class Discussion

  def display
    is_displayed = param("discussion_masked_#{id}".to_sym) != '1'
    (
      self.titre +
      self.avertissement_confidentialite +
      messages.collect do |imess|
        imess.as_li
      end.join.in_ul(class: 'discussion') +
      Frigo::Discussion::Message.form_message(premier = false)
    ).in_div(id: "discussion-#{id}", display: is_displayed)
  end

  def avertissement_confidentialite
    'Notez que cette discussion est strictement confidentielle.'.in_div(class: 'right small italic')
  end

end #/Discussion
end #/Frigo
