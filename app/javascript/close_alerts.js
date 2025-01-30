'use strict';

window.moj.Modules.CloseAlerts = {
  init: function() {
    this.bindEvents();
  },

  bindEvents: function() {
    var self = this;

    $('.alert-box a.close').on('click', function(e) {
      e.preventDefault();
      self.closeAlert($(e.target));
    });
  },

  closeAlert: function($el) {
    $el.closest('.alert-box').fadeOut();
  }
};
