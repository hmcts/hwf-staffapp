'use strict';

window.moj.Modules.RefundModule = {
  init: function() {
    this.bindEvents();
    this.preload();
  },

  bindEvents: function() {
    var self = this;
    var day = null;
    var month = null;
    var year = null;

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

  compareDates: function() {
    self.latest_date = new Date();
    // 3 months ago
    latest_date.setMonth(latest_date.getMonth() - 3)
    self.date_paid = new Date(`${month} ${day} ${year}`)
    if(day.length < 1 || month.length < 1 || year.length < 1 || date_paid == 'Invalid Date'){
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
