# encoding: UTF-8
=begin

Module de construction du bloc des "hot news" en bas
de la page d'accueil du site.

Ce module n'est chargé que s'il faut actualisé ce bloc, après
un changement dans les informations.

=end
class SiteHtml

  # Section des dernières actualités, en bas de la page
  # d'accueil.
  def section_hot_news
    (
      bloc_actualite_if_any(:divers)
    ).in_section(id:'hot_news')
  end

  # ---------------------------------------------------------------------
  #   Bloc des actualités
  # ---------------------------------------------------------------------

  def bloc_actualite_if_any actu_id
    send("bloc_actualite_#{actu_id}".to_sym).in_div(class:'blocactu')
  end


  # ---------------------------------------------------------------------
  #     FORUM
  # ---------------------------------------------------------------------
  def bloc_actualite_forum
    titre_bloc_actu("Forum", "forum/home") +
    "Derniers messages :".in_span(class:'label') +
    derniers_messages_forum
  end

  def derniers_messages_forum
    @derniers_messages_forum ||= begin
      table_contents = site.dbm_table(:forum, 'posts_content')
      last_messages_forum.collect do |dpost|
        pid       = dpost[:id]
        puser     = User::get(dpost[:user_id])
        pcreated  = dpost[:created_at]
        pcontent = table_contents.get(pid, colonnes:[:content])[:content]

        pseudo    = puser.pseudo
        puser     = " (#{pseudo})".in_span(class:'tiny')
        plongcontent = pcontent[0..200]
        plongcontent += " […]" if pcontent.length > 200
        pcontent  = pcontent[0..30] + " […]"
        plink     = "post/#{pid}/read?in=forum"
        title     = "Cliquer ici pour lire le dernier message de #{pseudo}, datant du #{pcreated.as_human_date(true, true, ' ')} : #{plongcontent.purified.gsub(/\n/,' ')}"
        "#{DOIGT}“#{pcontent}”#{puser}".in_a(href: plink, target:"_blank", title: title.strip_tags).in_div(class:'actu')
      end.join('')
    end
  end
  def last_messages_forum
    drequest = {
      where: "SUBSTRING(options,1,1) = '1'",
      order:  'created_at',
      limit:  3,
      colonnes: [:user_id, :created_at]
    }
    site.dbm_table(:forum, 'posts').select(drequest)
  end

  # ---------------------------------------------------------------------
  #     DIVERS ACTUALITÉS
  # ---------------------------------------------------------------------

  # Les dernières actualités diverses sont consignées
  # dans le fichier : ./hot/last_actualites.rb
  def bloc_actualite_divers
    titre_bloc_actu("Divers") +
    "Dernières actualités :".in_span(class:'label') +
    dernieres_actualites_divers +
    "[les voir toutes]".in_a(href:'site/updates', class:'tiny').in_div(class:'right')
  end
  def dernieres_actualites_divers
    require './hot/last_actualites'
    dernieres_actualites_generales.collect do |arrdata|
      message, hdate = arrdata
      t =
        case hdate
        when String
          djour, dmois, dannee = hdate.split(/[ \/]/)
          Time.new(dannee.to_i, dmois.to_i, djour.to_i).to_i
        when Fixnum
          hdate
        end
      "#{DOIGT}#{message}#{as_small_date t}".in_div(class:'actu')
    end.join('')
  end


  # ---------------------------------------------------------------------
  #     HELPER METHODES
  # ---------------------------------------------------------------------

  # Un titre de bloc d'actualité (avec "News" écrit flottant à droite)
  def titre_bloc_actu titre, url = nil
    titre = titre.upcase
    titre = titre.in_a( href: url ) unless url.nil?
    (
      "#{PUNAISE_ROUGE}".in_span(class:'relative') +
      "#{titre}"
    ).in_div(class:'title')
  end

  # On envoie le timestamp et la méthode retourne le span
  # avec la date entre parenthèse en tiny
  def as_small_date ti = Time.now.to_i
    " (#{ti.as_human_date})".in_span(class:'tiny')
  end

end #/SiteHtml
