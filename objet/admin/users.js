if(undefined == window.Dashboard){window.Dashboard = {}}
$.extend(window.Dashboard,{

  // note : DATA_OPERATIONS est défini en ruby
  on_choose_operation: function(){
    var ope     = $('select#opuser_ope').val();
    var data_op = DATA_OPERATIONS[ope] ;

    // Champ pour une valeur courte
    $('div#div_short_value')[data_op.short_value ? 'show' : 'hide']();
    $('div#short_value_explication').html(data_op.short_value || '');
    $('input#opuser_short_value').val('');

    // Champ pour une valeur longue
    $('div#div_long_value')[data_op.long_value ? 'show' : 'hide']();
    $('div#long_value_explication').html(data_op.long_value || '');
    $('textarea#opuser_long_value').val('');
  }
})
