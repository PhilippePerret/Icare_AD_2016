$(document).ready(function(){

  // Un compteur sur le message qui est peut-être affiché
  // sur la page. Mais on ne le met pas si des messages
  // d'erreur sont affichés
  if($('#flash').length){
    if( $('#flash div.error').length == 0 ){
      var coefH = $('#flash').height() / 40;
      setTimeout($.proxy(Flash, 'clean', null, true), 5000 * coefH)
    }
  }

  UI.auto_selection_text_fields();

  // Surveille tous les champs d'édition marqués "warning",
  // en général pour mettre en exergue une erreur
  UI.observe_champs_warning();

})
