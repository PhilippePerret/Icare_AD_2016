# encoding: UTF-8
class Frigo
class Discussion

  def display
    self.titre +
    self.avertissement_confidentialite +
    messages.collect do |imess|
      imess.as_li
    end.join.in_ul(class: 'discussion') +
    Frigo::Discussion::Message.form_message(premier = false)
  end

  def avertissement_confidentialite
    'Notez que cette discussion est strictement confidentielle.'.in_div(class: 'right small italic')
  end

end #/Discussion
end #/Frigo
