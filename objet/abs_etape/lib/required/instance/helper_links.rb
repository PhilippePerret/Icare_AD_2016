# encoding: UTF-8
class AbsModule
class AbsEtape


  # RETURN un lien vers le livre/collection Narration
  #
  # NOTES
  #
  #   * alias def lien_narration
  #
  def link_narration params = nil
    params =
      case params
      when String then {titre: params}
      else params
      end
    params ||= Hash.new
    titre = params.delete(:titre) || "Narration"
    page_id = params.delete(:page_id) || params.delete(:page) || params.delete(:pn)
    params.merge!(href: "http://www.laboiteaoutilsdelauteur.fr/narration/#{page_id}/show")
    titre.in_a(params)
  end
  alias :lien_narration :link_narration
end #/AbsEtape
end #/AbsModule
