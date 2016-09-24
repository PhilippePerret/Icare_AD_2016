# encoding: UTF-8

class ::Array

  # Le `self' doit être une liste de cette forme :
  #     [
  #       <value>, <titre>[, <true si selected ou rien>],
  #       <value>, <titre>[, <true si selected ou rien>],
  #       etc.
  #     ]
  def in_select attrs = nil
    selected = attrs.delete(:selected)
    selected = selected.to_s
    self.collect do |doption|
      data_option = {value: doption[0]}
      if (doption[2] == true) || (selected != "" && selected == doption[0].to_s)
        data_option = data_option.merge( selected: true)
      end
      doption[1].to_s.in_option(data_option)
    end.join('').in_select attrs
  end

  def nil_or_empty?
    self.count == 0
  end
end
