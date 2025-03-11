'use strict';

window.moj.Modules.GtmTrackTimestamps = {
  hompage: function() {
    moj.Modules.Cookies.set('homepage_visited_timestamp', Date.now());
  },

  getTimestamps: function() {
    var homepage_timestamp = parseInt(moj.Modules.Cookies.get('homepage_visited_timestamp'), 10);
    var current_page_timestamp = Date.now();
    var transition_time_in_ms = current_page_timestamp - homepage_timestamp;

    return {
      'homepage': homepage_timestamp,
      'currentPage': current_page_timestamp,
      'transitionTimeInMs': transition_time_in_ms
    }
  },

  processedApplication: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Processed_Application_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'processedApplicationTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  deletedApplication: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Deleted_Application_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'deletedApplicationTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  evidenceApplication: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Evidence_Application_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'evidenceApplicationTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  partPaymentApplication: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Part_Payment_Application_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'partPaymentApplicationTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },


  evidence: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Evidence_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'evidenceTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  partPayment: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Part_Payment_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'partPaymentTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  yourLastApplication: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Yourlastapp_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'lastAppTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  serchPerformed: function(search_result) {
    var results = $('table.search-results').length;
    var search_query = $('#completed_search_reference').val();

    if(search_query.length == 0){
      search_query = '(Blank)';
    }

    if(results > 0){
      search_result = 'Success';
    }

    dataLayer.push({
      'event': 'SearchPerformed',
      'searchResult': search_result,
      'searchQuery': search_query
    });
  },

  searchResultClick: function() {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': 'Searchresult_Timestamp',
      'hompageTimestamp': timestamps.homepage,
      'searchResultClickTimestamp': timestamps.currentPage,
      'transitionTimeInMs': timestamps.transitionTimeInMs
    });
  },

  sectionLinkClick: function(section_name) {
    var timestamps = this.getTimestamps()

    dataLayer.push({
      'event': section_name,
      'hompageTimestamp': timestamps.homepage
    });
  },

  trackLinksClicked: function() {
    $('a.waiting-for-evidence').on('click', function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('waiting-for-evidence-section');
    });

    $('a.waiting-for-part_payment').on('click', function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('waiting-for-part-payment-section');
    });

    $('a.processed-applications').on('click', function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('processed-applications-section');
    });

    $('a.deleted-applications').on('click', function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('deleted-applications-section');
    });

    $('.updated_applications a').on('click', function(){
      moj.Modules.GtmTrackTimestamps.yourLastApplication();
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('your-last-applications-section');
    });

    $('table.search-results a').on('click', function(){
      moj.Modules.GtmTrackTimestamps.searchResultClick();
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('search-results-section')
    });
  },

  bindHomepageEvents: function() {
    moj.Modules.GtmTrackTimestamps.trackLinksClicked();

    if($('#completed_search_reference').val().length > 0){
      moj.Modules.GtmTrackTimestamps.serchPerformed('Failure');
    }

    $('.search-button').on('click', function(){
      moj.Modules.GtmTrackTimestamps.serchPerformed('');
    });
  },

  trackErrorMessage:  function() {
    var error_messages = moj.Modules.GtmTrackTimestamps.readErrorMessages()
    if(error_messages.length > 0) {
      dataLayer.push({
        'event': 'ErrorMessage',
        'errorMessageText': error_messages
      });
    }
  },

  readErrorMessages: function(){
    var val = []
    var error_messages = '';

    if($('.govuk-error-summary__body').length > 0){
      error_messages = $('.govuk-error-summary__body').text()
    } else if($('label.error').length > 0) {
      $('label.error').each(function() {
        val.push($( this ).text());
      });
      error_messages = val.join(', ');
    }

    return error_messages;
  }
};
