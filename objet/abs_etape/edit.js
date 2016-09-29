if(undefined==window.AbsEtape){window.AbsEtape={}}
$.extend(window.AbsEtape,{

  // Méthode appelée quand on modifie les liens
  // Elle crée les liens pour les voir
  onchange_liens:function(){
    var val = $('textarea#etape_liens').val().trim();
    if(val == ''){
      liens_formated = '';
    }else{
      var liens = val.replace(/\r/g,'').split("\n");
      var liens_formated = '';
      for(var i=0,len=liens.length;i<len;++i){
        var dlien = liens[i].split('::');
        if (dlien[1] == 'collection'){
          href  = 'www.laboiteaoutilsdelauteur.fr/narration/'+dlien[0]+'/show';
          titre = dlien[2] || ('Page narration #' + dlien[0]);
        }else{
          href = dlien[0];
          titre = dlien[1];
        }
        liens_formated += '<div><a href="http://'+href+'" target="_new">'+titre+'</a></div>';
      }
    }
    $('div#liens_formated').html(liens_formated);
  }
})

// Quand la page est chargée
$(document).ready(function(){

  // On met en forme les liens éventuels
  AbsEtape.onchange_liens();


})
