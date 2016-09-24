if(undefined == window.UI){window.UI = {}}

$.extend(window.UI,{

  HEIGHT_TEXTAREA: '50px',

  // Tous les Jid des éléments à masquer quand la
  // fenêtre est bloquée.
  ELEMENTS2MASK_WND_BLOQUEE: [
    'section#header',
    'section#footer',
    'section#debug',
    'section#left_margin',
    'section#content > h1',
    'section#content > h2',
    'section#social_network',
    'form#taches_widget'
  ],

  /** Méthode permettant de bloquer la page, i.e. de rendre
    * la section#content fixe et de faire disparaitre les
    * éléments de page inutiles.
    * Utile pour les listes qui sont toujours embêtantes
    * à utiliser.
    *
    * De plus :
    *   - On place un bouton en haut à gauche pour débloquer
    *     la page.
    *   - On réduit tous les textarea, mais en plaçant un
    *     observateur qui va les mettre en haut à gauche
    *     dès qu'on focussera dedans et les remettra
    *     en place après au blur
    */
  bloquer_la_page:function(bloquer){
    var css_content = {}
    if(bloquer){
      css_content = $.extend(css_content, {
        'padding'     : '0'
      })
    }
    css_content = $.extend(css_content, {
      'position':(bloquer ? 'fixed' : 'relative'),
      'top':(bloquer ? '0' : 'none'),
      'left':(bloquer ? '50px' : 'none'),
      'margin-left':(bloquer ? '0' : '')
    })
    $('section#content').css(css_content);
    $(this.ELEMENTS2MASK_WND_BLOQUEE).each(function(i,e){
        if(bloquer){ $(e).hide()}
        else{$(e).show()}
    })

    if(bloquer){
      // On place un bouton pour débloquer la page
      this.bouton_debloquer();
      // On réduit les textarea et on place des observers
      $('textarea').css({
        'height': this.HEIGHT_TEXTAREA, 'max-height':this.HEIGHT_TEXTAREA,
      'min-height':this.HEIGHT_TEXTAREA});
      $('textarea').bind('focus', function(ev, ui){UI.onfocus_textarea(ev, $(this))});
      $('textarea').bind('blur',  function(ev, ui){ UI.onblur_textarea(ev, $(this))});
    } else {
      // On place un bouton pour bloquer la page
      this.bouton_bloquer();
    }

  },

  debloquer_la_page:function(){
    this.bloquer_la_page(false)
  },

  old_textarea_height:  null,
  old_textarea_width:   null,
  onfocus_textarea:function(ev, o){
    this.old_textarea_height = o.css('height');
    this.old_textarea_width = o.css('width');
    var txth = (window.innerHeight - 100) + 'px' ;
    console.log(txth)
    o.css({
      'position':'fixed', top:'40px', left:'40px',
      'min-height': txth,
      'height': txth,
      'max-height': txth,
      'width': '800px'
    })
  },
  onblur_textarea:function(ev, o){
    o.css({
      'position':'', top:'', left:'',
      'height':this.HEIGHT_TEXTAREA,
      'min-height':this.HEIGHT_TEXTAREA,
      'max-height':this.HEIGHT_TEXTAREA,
      'width': this.old_textarea_width
    })
  },

  bouton_debloquer:function(){
    this.build_bouton_debloquer('debloquer')
  },
  bouton_bloquer:function(){
    this.build_bouton_debloquer('bloquer')
  },
  build_bouton_debloquer(pour){
    $('a#bouton_bloquer').remove();
    var btn_name = pour == 'bloquer' ? 'Bloquer' : 'Débloquer' ;
    var sty = 'position:fixed;bottom:10px;right:10px;border:1px solid #888;padding:2px 8px';
    var bouton = '<a id="bouton_bloquer" onclick="$.proxy(UI,\''+pour+'_la_page\')(true)" style="'+sty+'" class="tiny">'+btn_name+'</a>';
    $('body').append(bouton);
  }

})
