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

  serchPerformed: function() {
    var results = $('table.search-results').size();
    var search_result = 'Failure';

    if(results > 0){
      search_result = 'Success';
    }

    dataLayer.push({
      'event': 'SearchPerformed',
      'searchResult': search_result
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

  bindHomepageEvents: function() {
    $('.updated_applications a').click(function(){
      moj.Modules.GtmTrackTimestamps.yourLastApplication();
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('your-last-applications-section');
    });

    $('.waiting-for-evidence a').click(function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('waiting-for-evidence-section');
    });

    $('.waiting-for-part_payment a').click(function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('waiting-for-part-payment-section');
    });

    $('a.processed-applications').click(function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('processed-applications-section');
    });

    $('a.deleted-applications').click(function(){
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('deleted-applications-section');
    });

    if($('#completed_search_reference').val().length > 0){
      moj.Modules.GtmTrackTimestamps.serchPerformed();
    }

    $('table.search-results a').click(function(){
      moj.Modules.GtmTrackTimestamps.searchResultClick();
      moj.Modules.GtmTrackTimestamps.sectionLinkClick('search-results-section')
    });
  }
};
