'use strict';

window.moj.Modules.ApplicantsPartnerOver61 = {
  init: function() {
    // this.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#application_threshold_exceeded_false', function() {
      $('#application_partner_over_61_false, #application_partner_over_61_true').prop('checked', false);
    });
  }
};
