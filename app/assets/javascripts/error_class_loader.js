
$.when( $.ready ).then(function() {

  if($('label.error').size() > 0){

    $('label.error').parents('div.govuk-form-group').each(function( index ) {
      if($(this).children(':input').size()>0){
        $(this).children(':input').addClass('govuk-input--error');
      }
    });
  }

  $('label.error').parentsUntil('govuk-form-group', '.group-level').addClass('govuk-form-group--error')

  $('.govuk-date-input.error_dates .govuk-date-input__input').each(function( index ) {
    $(this).addClass('govuk-input--error');
  });

});

