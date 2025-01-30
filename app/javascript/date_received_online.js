'use strict';

window.moj.Modules.DateReceivedOnlineModule = {
  init: function() {
    this.bindEvents();
    this.loadDateSubmitted();
    this.loadDateReceived();
  },

  bindEvents: function() {
    var self = this;

    $('input[id="online_application_day_date_received"]').on('keyup', function(t){
      self.loadDateReceived();
    });
    $('input[id="online_application_month_date_received"]').on('keyup', function(t){
      self.loadDateReceived();
    });
    $('input[id="online_application_year_date_received"]').on('keyup', function(t){
      self.loadDateReceived();
    });
  },

  loadDateReceived: function() {
    var received_day = $('input[id="online_application_day_date_received"]').val();
    var received_month = $('input[id="online_application_month_date_received"]').val();
    var received_year = $('input[id="online_application_year_date_received"]').val();

    this.received_date = new Date(received_month + '/' + received_day + '/' + received_year);
    this.compareDates();
  },

  compareDates: function() {
    if(this.date_sumitted == 'Invalid Date' || Date.now() < this.received_date){
      // invalid date
      $('fieldset.discretion_applied').hide();
    } else {
      this.received_date.setMonth(this.received_date.getMonth() - 3);
      this.toggleDiscretionBlock();
    }
  },

  toggleDiscretionBlock: function() {
    if(this.date_sumitted < this.received_date) {
      $('fieldset.discretion_applied').show();
    } else {
      $('fieldset.discretion_applied').hide();
    }
  },

  loadDateSubmitted: function() {
    this.date_sumitted = new Date($('.date_sumitted').text());
  },
};
