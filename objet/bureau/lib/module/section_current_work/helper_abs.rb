# encoding: UTF-8
class AbsModule
class AbsEtape

  def liens_edit_if_admin
    user.admin? || (return '')
    '[edit]'.in_a(href: "abs_etape/#{id}/edit")
  end

  # Liste des objectifs, ceux de l'étape elle-même ainsi que
  # ceux de ses travaux-types, formatés comme une suite de div.objectif
  # à insérer directement dans l'étape
  def objectifs_formated
    ([objectif.nil_if_empty]+ travaux_types.objectifs).compact.collect do |t|
      t.in_div(class: 'objectif')
    end.join
  end

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
         # Maintenant, c'est sur la boite à outils qu'on peut
         # consulter les pages de narration. On va essayer de se
         # servir de la session pour vérifier que l'user peut visiter
         # la page normalement, en envoyant dans l'url l'identifiant
         # de l'user.
         #
         # Note : l'ID de la page doit correspondre au vrai identifiant
         # sur la collection. Le titre doit être mis, il ne peut plus
         # être récupéré.
         #
         # On envoie dans l'adresse les informations sur  l'icare afin
         # de pouvoir créer son profil s'il n'existe pas. Mais seulement
         # s'il est actif.
         #
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

  def minifaq_formated
    (site.folder_objet+'abs_minifaq/lib/module/formulaire').require
    table_minifaq = site.dbm_table(:modules, 'mini_faq')
    drequest = {
      where: {numero: numero, abs_module_id: self.module_id},
      colonnes: [:content, :user_id]
    }
    hdata = table_minifaq.select(drequest)
    if hdata.empty?
      # Aucune Q/R pour cette étape
      "#{user.pseudo}, soyez #{user.f_la} prem#{user.f_iere} à poser une question sur cette étape de travail.".in_p(class: 'italic')
    else
      hdata.collect do |hminiqr|
        # On indique quand c'est une propre question de l'user courant
        # Ça n'est pas uniquement pour faire joli, c'est aussi pour que
        # l'icarien puisse trouver plus facilement sa réponse.
        classes = ['mf_qr']
        classes << 'yours' if hminiqr[:user_id] == user.id
        hminiqr[:content].in_div(class: classes.join(' '), id: "mf_qr_#{hminiqr[:id]}")
      end.join
    end
  end
  #/minifaq_formated

end #/AbsEtape
end #/AbsModule
