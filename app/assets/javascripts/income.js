'use strict';

window.moj.Modules.IncomeModule = {
  init: function() {
    this.bindEvents();
    this.checkStateOnLoad();
  },

  bindEvents: function() {
    var self = this;
    $('input[id*="application_dependents"]').on('click', function() {
      $('#income-input').show();
    });

    $('input[id="application_income"]').on('change', function(target){
      self.roundIncomeValue(target);
    });
    $('input[id="evidence_income"]').on('change', function(target){
      self.roundIncomeValue(target);
    });
  },

  checkStateOnLoad: function() {
    $('#income-input').toggle($('input[id*="application_dependents"]').is(':checked'));
  },

  roundIncomeValue: function(target) {
    var income = $(target.currentTarget).val()
    if(isNaN(income)) {
      $(target.currentTarget).val('Value is not a number');
    } else {
      $(target.currentTarget).val(Math.round(income));
    }
  },
};
