'use strict';

window.moj.Modules.RefundModule = {
  init: function() {
    this.bindEvents();
  },

  bindEvents: function() {
    var self = this;
    var day = 0;
    var month = 0;
    var year = 0;

    $('input[id="application_day_date_fee_paid"]').on('keyup', function(t){
      self.loadFeePaidDate();
    });
    $('input[id="application_month_date_fee_paid"]').on('keyup', function(t){
      self.loadFeePaidDate();
    });
    $('input[id="application_month_date_fee_paid"]').on('keyup', function(t){
      self.loadFeePaidDate();
    });
  },

  compareDates: function() {
    self.latest_date = new Date();
    // 3 months ago
    latest_date.setMonth(latest_date.getMonth() - 3)
    self.date_paid = new Date(`${month} ${day} ${year}`)

    if(date_paid == 'Invalid Date'){
      // invalid date
    } else {
      this.toggleDiscretionBlock();
    }
  },

  toggleDiscretionBlock: function() {
    if(date_paid<= latest_date) {
      $('fieldset.discretion_applied').show();
    } else {
      $('fieldset.discretion_applied').hide();
    }
  },

  loadFeePaidDate: function() {
    self.day = $('input[id="application_day_date_fee_paid"]').val();
    self.month = $('input[id="application_month_date_fee_paid"]').val();
    self.year = $('input[id="application_year_date_fee_paid"]').val();
    this.compareDates();
  },

};
