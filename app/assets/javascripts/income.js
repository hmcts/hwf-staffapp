'use strict';

window.moj.Modules.IncomeModule = {
  init: function() {
    this.bindEvents();
    this.checkStateOnLoad();
  },

  bindEvents: function() {
    $('input[id*="application_dependents"]').on('click', function() {
      $('#income-input').show();
    });
  },

  checkStateOnLoad: function() {
    if ($('input[id*="application_dependents"]').is(':checked')) {
      $('#income-input').show();
    } else {
      $('#income-input').hide();
    }
  }
};
