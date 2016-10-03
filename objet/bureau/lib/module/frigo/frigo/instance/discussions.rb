# encoding: UTF-8
class Frigo

  # Retourne la discussion à écrire dans la page
  def current_discussion
    @current_discussion ||= begin
      hdis = has_discussion_with_current?
      hdis != nil || raise('Il devrait exister une discussion, ici…')
      Frigo::Discussion.new(hdis[:id])
    end
  end
  # /current_discussion

  def current_discussion= dis
    @current_discussion = dis
  end


  # Créer une discussion sur le frigo
  #
  # Retourne le texte à écrire dans la fenêtre
  def create_discussion

    # Si le frigo n'existe pas, il faut le créer
    self.exist? || begin
      self.create
      if self.exist?
        debug "  = Frigo créé avec succès"
      else
        raise 'Le frigo n’a pas pu être créé…'
      end
    end

    # On crée la discussion dans ce frigo
    dis = Frigo::Discussion.new
    dis.create
    dis.display
  end
  # /create_discussion

  # Toutes les discussions. C'est un objet pluriel
  def discussions
    @discussions ||= Discussions.new(self.owner)
  end

  class Discussions

    # Propriétaire des discussions
    attr_reader :owner

    def initialize owner
      @owner = owner
    end

    # Affichage de toutes les discussions du propriétaire
    def display
      list.collect do |dis|
        frigo.current_discussion = dis
        dis.display
      end.join.in_div(class: 'discussions')
    end

    def list
      @list ||= begin
        drequest = {
          where: {owner_id: owner.id},
          colonnes: []
        }
        dbtable_frigo_discussions.select(drequest).collect do |hdis|
          Frigo::Discussion.new(hdis[:id])
        end
      end
    end

  end#/Discussions
end#/Frigo
