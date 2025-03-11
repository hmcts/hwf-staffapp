'use strict';

window.moj.Modules.SavingsModule = {
  init: function() {
    this.bindEvents();
  },

  bindEvents: function() {
    var self = this;
    $('input[id="application_amount"]').on('change', function(target){
      self.roundIncomeValue(target);
    });
  },

  roundIncomeValue: function(target) {
    var income = $(target.currentTarget).val()
    if(!isNaN(income)) {
      $(target.currentTarget).val(Math.round(income));
    }
  },
};
