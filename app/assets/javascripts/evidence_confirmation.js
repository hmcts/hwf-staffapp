'use strict';

window.moj.Modules.EvidenceConfirmationModule = {
  init: function() {
    this.bindEvents();
    this.checkStateOnLoad();
  },

  bindEvents: function() {
    $('#accuracy-form input[id*="correct_false"]').on('click', function() {
      $('#reason-input').show();
    });

    $('#accuracy-form input[id*="correct_true"]').on('click', function() {
      $('#reason-input').hide();
    });
  },

  checkStateOnLoad: function() {
    if ($('#accuracy-form input[id*="correct_false"]').is(':checked')) {
      $('#reason-input').show();
    } else {
      $('#reason-input').hide();
    }
  }
};
