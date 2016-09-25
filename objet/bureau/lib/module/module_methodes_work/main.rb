# encoding: UTF-8
=begin

  Module de méthodes partagées par les AbsEtapes et les AbsTravauxTypes
  pour construire le travail

=end
module MethodesTravail

  # {String} Le travail de l'étape, formaté
  def travail_formated
    ERB.new(travail).result(self.bind)
  end

  # {String} Code HTML pour afficher les liens de l'étape et
  # des travaux-type
  def liens_formated
    (liens.split("\n") + travaux_types.liens).collect do |dlink|
      dlink.nil_if_empty != nil || next
      # Plusieurs formats de mail ont été injectés au cours
      # des différentes versions de l'atelier.
      formate_link dlink
    end.compact.join
  end

  def formate_link dlink
    page, titre = nil, nil
    if (res = dlink.match(/^([0-9]{1,4})::(livre|collection)(::(.*))?$/))
      page  = res[1]
      type  = res[2]
      titre = res[4]

      case type
      when 'livre'
        href = "http://www.laboiteaoutilsdelauteur.fr/narration/#{page}/show"
        titre.in_a(href: href)
      when 'collection'
        # cf. N0001
         href = "http://www.laboiteaoutilsdelauteur.fr/narration/#{page}/show"
         if cu.actif?
           #  TODO CORRIGER
           href += "&fromicare=1&cpicare=#{cu.cpassword}&micare=#{cu.mail}&idicare=#{cu.id}&picare=#{cu.pseudo}"
           href += "&xicare=#{cu.sexe}"
         end
        (titre || "[titre de page non défini]").in_a(href: href)
      end
    else
      # Un lien externe explicite
      # "<url>::<titre lien>"
      href, titre = dlink.split('::')
      href.start_with?('http://') || href.prepend("http://")
      titre.in_a(href: href)
    end

  end

  # {String} Code HTML pour afficher la méthode de travail si elle
  # est définie.
  def methode_formated
    ERB.new(methode).result(self.bind)
  end

end