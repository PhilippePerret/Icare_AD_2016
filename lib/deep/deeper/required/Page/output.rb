# encoding: UTF-8
=begin

=end
class Page

  def output
    unless site.ajax?
      final_code = cgi.html{cgi.head{head}+cgi.body{body}}
      app.benchmark('CODE HTML FINAL BUILT') rescue nil
      # Correspond aussi à la fin de la méthode output du site
      app.benchmark('<- SiteHtml#output')
      app.benchmark_fin #rescue nil
      cgi.out{final_code}
      # RIEN NE PEUT PASSER ICI
    else
      # Retour d'une requête ajax
      Ajax.output
    end
  end

  # Retourne TRUE si l'objet est une collection, pour schema.org,
  # comme une dictionnaire (scénodico) ou une liste comme filmodico.
  # Cela a pour effet d'ajouter "itemscope itemtype='http://schema.org/Collecion'"
  # dans la section de contenu de la page.
  #
  # @usage: utiliser page.is_collection pour définir que c'est une
  # collection.
  def collection?
    !!@is_collection
  end
  def is_collection value = true
    @is_collection = value
  end

  def ajout_schema_org
    if collection?
      ' itemscope itemtype="http://schema.org/Collection"'
    else
      ''
    end
  end

  def head
    @head ||= begin
      with_fonts = true # Mettre ONLINE quand on ne peut pas avoir de connexion
      fonts_google = if with_fonts
        <<-FONTS
        <link href='https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=latin-ext,latin' rel='stylesheet' type='text/css'>
        <!--[if lt IE 9]>
        <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
        FONTS
      else
        ""
      end
      <<-HEAD
<meta content="text/html; charset=utf-8" http-equiv="Content-type">
<title>#{page.title}</title>
<link rel="shortcut icon" href="view/img/favicon.ico?" type="image/x-icon">
<link rel="icon" href="view/img/favicon.ico?" type="image/x-icon">
#{self.balise_meta_description}
<base href="#{site.base}" />
#{fonts_google}
#{self.javascript}
#{self.css}
#{self.raw_css}
#{self.raw_javascript}
      HEAD
    end
  end

  def body
    @body ||= begin
      app.benchmark('-> Page#body')
      res =
        page.header         +
        (left_margin? ? page.left_margin : '') +
        page.content        +
        page.footer         +
        app.div_flash       +
        page.section_debug
      app.benchmark('<- Page#body')
      res
    end
  end
  # /body

end
