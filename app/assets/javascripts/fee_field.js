'use strict';

window.moj.Modules.FeeField = {
  field: '#application_fee',
  threshold: 10480,
  init: function() {
    var self = this,
        $field = $(self.field);

    if($field.length) {
      self.bindEvents($field);
    }
  },

  bindEvents: function($field) {
    var self = this;

    $field.on('blur', function() {
      self.checkVal($field);
    });
  },

  checkVal: function($field) {
    var self = this,
        f = Math.ceil($field.val());

    if(!isNaN(f) && f > self.threshold) {
      $('#large-fee-message').show();
    } else {
      $('#large-fee-message').hide();
    }
  }
};
