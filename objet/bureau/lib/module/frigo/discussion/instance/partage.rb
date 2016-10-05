# encoding: UTF-8
=begin

  Toutes les méthodes qui définissent le partage de la discussion.

=end
class Frigo
class Discussion

  def set_partage
    frigo.owner? || begin
      raise 'Seriez-vous en train d’essayer de forcer une discussion qui ne vous appartient pas ?…'
    end
    set(options: options.set_bit(0, param(:discussion_partage).to_i))

    flash "Le partage de cette discussion a été mise à #{shared_hvalue}"
  end

  def shared?
    options[0].to_i > 0
  end

  def shared_world?
    options[0].to_i > 1
  end

  def shared_hvalue
    case options[0].to_i
    when 0  then '“privée” : seul votre interlocuteur peut la lire.'
    when 1  then '“semi-publique” : seuls les icariens peuvent la consulter.'
    when 2  then '“publique” : tout visiteur, même non icarien, peut la lire.'
    end
  end

end #/Discussion
end #/Frigo
