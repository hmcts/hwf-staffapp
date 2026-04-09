'use strict';

window.moj.Modules.PermanentDelete = {
  init: function() {
    this.bindEvents();
  },

  bindEvents: function() {
    var self = this;

    $('.permanent-delete-trigger').on('click', function(e) {
      e.preventDefault();
      self.showConfirmation();
    });

    $('.permanent-delete-cancel').on('click', function(e) {
      e.preventDefault();
      self.hideConfirmation();
    });
  },

  showConfirmation: function() {
    $('.permanent-delete-trigger').hide();
    $('.permanent-delete-confirmation').show();
  },

  hideConfirmation: function() {
    $('.permanent-delete-confirmation').hide();
    $('.permanent-delete-trigger').show();
  }
};
