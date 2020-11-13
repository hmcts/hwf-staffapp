'use strict';

window.moj.Modules.RefundModule = {
  init: function() {
    this.bindEvents();
    this.preload();
  },

  bindEvents: function() {
    var self = this;

    $('input[id="application_day_date_fee_paid"]').on('keyup', function(t){
      self.loadFeePaidDate();
    });
    $('input[id="application_month_date_fee_paid"]').on('keyup', function(t){
      self.loadFeePaidDate();
    });
    $('input[id="application_year_date_fee_paid"]').on('keyup', function(t){
      self.loadFeePaidDate();
    });
  },

  loadDateReceived: function() {
    var received_day = $('input[id="application_day_date_received"]').val();
    var received_month = $('input[id="application_month_date_received"]').val();
    var received_year = $('input[id="application_year_date_received"]').val();
    self.received_date = new Date(received_month + '/' + received_day + '/' + received_year)
  },

  compareDates: function() {
    this.loadDateReceived();
    received_date.setMonth(received_date.getMonth() - 3)
    self.date_paid = new Date(month + '/' + day + '/' + year)

    if(day.length < 1 || month.length < 1 || year.length < 1 || date_paid == 'Invalid Date'){
      // invalid date
    } else {
      this.toggleDiscretionBlock();
    }
  },

  toggleDiscretionBlock: function() {
    if(date_paid < received_date) {
      $('fieldset.discretion_applied').show();
    } else {
      $('fieldset.discretion_applied').hide();
    }
  },

  loadFeePaidDate: function() {
    self.day = $('input[id="application_day_date_fee_paid"]').val();
    self.month = $('input[id="application_month_date_fee_paid"]').val();
    var year_value = $('input[id="application_year_date_fee_paid"]').val();

    // if you pass just 2 digit for year Date() makes it full year
    if(year_value.length == 2) {
      self.year = 0;
    } else {
      self.year = year_value;
    }

    this.compareDates();
  },

  preload: function() {
    var self = this;
    if($('input[id="application_day_date_fee_paid"]').length == 1){
      $('input[id="application_day_date_fee_paid"]').ready(function() {
        self.loadFeePaidDate();
      });
    }
  },

};
