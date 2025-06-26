'use strict';

window.moj.Modules.JsonSearcherModule = (function() {
  // Make codes accessible to both init and findMatches
  let codes = [];

  // Ideally search for fee (amount), jurisdictions, service type and event type.
  return {
    init: function() {
      codes = window.moj.Modules.LoadCodesModule.getCodes();
      this.bindEvents();
    },

    bindEvents: function() {
      var self = this;
      $('input[id="fee_search"]').on('keyup', function(event){
        var searchTerm = $(event.target).val();
        self.findMatches(searchTerm);
      });
    },

    // Temorary solution for search to proove the concept
    findMatches: function (term) {
      var matches = codes.filter(item =>
        (item.code && item.code.toLowerCase().includes(term.toLowerCase())) ||
        (item.jurisdiction2 && item.jurisdiction2.name && item.jurisdiction2.name.toLowerCase().includes(term.toLowerCase())) ||
        (item.current_version && item.current_version.flat_amount && typeof item.current_version.flat_amount.amount === 'number' && item.current_version.flat_amount.amount.toString().includes(term)) ||
        (item.event_type && item.event_type.name && item.event_type.name.toLowerCase().includes(term.toLowerCase())) ||
        (item.service_type && item.service_type.name && item.service_type.name.toLowerCase().includes(term.toLowerCase()))
      );
      this.displayFees(matches);

    },

    displayFees: function (fees) {
      const resultsList = document.getElementById('fee-search-results');
      $('div.fee-search-results-block.govuk-inset-text').removeClass('govuk-visually-hidden');
      fees.forEach(fee => {
        if (resultsList) {
          $('span.search_result_count').text(fees.length)
          if (fee === fees[0]) resultsList.innerHTML = ''; // Clear only once at the start
            const li = document.createElement('li');
            li.textContent = `${fee.code}, £ ${fee.current_version.flat_amount.amount}, Description: ${fee.current_version.description}`;
            li.style.cursor = 'pointer';
            li.setAttribute('data-amount', fee.current_version.flat_amount.amount);
            li.classList.add('govuk-link');
            li.addEventListener('click', () => {
              const amount = li.getAttribute('data-amount');
              window.moj.Modules.JsonSearcherModule.fillFeeInput({ amount });
            });
            resultsList.appendChild(li);
        }
      });
      if (fees.length === 0) {
        $('span.search_result_count').text(0)
        resultsList.innerHTML = 'No matches found';
      }
    },

    fillFeeInput: function(fee) {
      $('input[id="application_fee"]').val(fee.amount);
    },
  };
})();
