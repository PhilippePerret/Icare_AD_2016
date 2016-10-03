# encoding: UTF-8
class Frigo
class Discussion

  def display
    self.titre +
    messages.collect do |imess|
      imess.as_li
    end.join.in_ul(class: 'discussion') +
    Frigo::Discussion::Message.form_message(premier = false)
  end

end #/Discussion
end #/Frigo
