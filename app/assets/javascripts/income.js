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
    $('#income-input').toggle($('input[id*="application_dependents"]').is(':checked'));
  }
};
