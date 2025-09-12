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
      $('#application_fee')
        .prop('readonly', true)
        .attr('aria-disabled', 'true')
        .css({
          'background-color': '#e0e0e0',
          'color': '#000000',
          'font-weight': 'bold'
        })

    },

    // Temorary solution for search to proove the concept
    findMatches: function (term) {
      var matches = codes.filter(item =>
        (item.code && item.code.toLowerCase().includes(term.toLowerCase())) ||
        (item.jurisdiction2 && item.jurisdiction2.name && item.jurisdiction2.name.toLowerCase().includes(term.toLowerCase())) ||
        (item.fee_versions && item.fee_versions[0] && item.fee_versions[0].flat_amount && typeof item.fee_versions[0].flat_amount.amount === 'number' && item.fee_versions[0].flat_amount.amount.toString().includes(term)) ||
        (item.event_type && item.event_type.name && item.event_type.name.toLowerCase().includes(term.toLowerCase())) ||
        (item.service_type && item.service_type.name && item.service_type.name.toLowerCase().includes(term.toLowerCase()))
      );
      this.displayFees(matches);

    },

    displayFees: function (fees) {
      const resultsList = document.getElementById('fee-search-results');
      $('div.fee-search-results-block.govuk-inset-text').removeClass('govuk-visually-hidden');
      let totalItems = 0;

      fees.forEach(fee => {
        if (resultsList && fee.fee_versions) {
          if (fee === fees[0]) resultsList.innerHTML = ''; // Clear only once at the start

          // Generate li for index 0 (current version)
          if (fee.fee_versions[0]) {
            const li0 = this.generateListItem(fee, 0);
            li0.addEventListener('click', () => {
              const amount = li0.getAttribute('data-amount');
              window.moj.Modules.JsonSearcherModule.fillFeeInput({ amount });
            });
            resultsList.appendChild(li0);
            totalItems++;
          }

          // Generate li for index 1 (previous version)
          if (fee.fee_versions[1]) {
            const li1 = this.generateListItem(fee, 1);
            li1.addEventListener('click', () => {
              const amount = li1.getAttribute('data-amount');
              window.moj.Modules.JsonSearcherModule.fillFeeInput({ amount });
            });
            resultsList.appendChild(li1);
            totalItems++;
          }
        }
      });

      $('span.search_result_count').text(totalItems);

      if (fees.length === 0) {
        $('span.search_result_count').text(0)
        resultsList.innerHTML = 'No matches found';
      }
    },

    fillFeeInput: function(fee) {
      $('input[id="application_fee"]').val(fee.amount);
    },

    generateListItem: function(fee, versionIndex) {
      const li = document.createElement('li');
      const currentFee = this.loadCurrentFeeValue(fee, versionIndex);
      const isCurrentFeeAmount = this.currentFeeAmount(fee, versionIndex);
      const version = fee.fee_versions[versionIndex];
      const versionLabel = versionIndex === 0 ? '(Current)' : '(Previous)';

      fee.service_type.name.toUpperCase()
      if (isCurrentFeeAmount) {
        li.textContent = `${fee.service_type.name.toUpperCase()} - ${fee.code} - £${currentFee} ${versionLabel}, Valid from: ${version.valid_from}`;
      } else {
        // There will need to be other flow for percentage fees - leaving it for now
        li.textContent = `${fee.service_type.name.toUpperCase()} - ${fee.code} - ${currentFee}% ${versionLabel}, Valid from: ${version.valid_from}`;
      }

      li.style.cursor = 'pointer';
      li.setAttribute('data-amount', currentFee);
      li.classList.add('govuk-link');
      return li;
    },

    currentFeeAmount: function(fee, versionIndex) {
     return fee.fee_versions && fee.fee_versions[versionIndex] && fee.fee_versions[versionIndex].flat_amount ? true : false;
    },

    loadCurrentFeeValue: function(fee, versionIndex) {
      if (fee.fee_versions && fee.fee_versions[versionIndex]) {
        const fee_version = fee.fee_versions[versionIndex];
        if (fee_version.flat_amount) {
          return fee_version.flat_amount.amount;
        } else if (fee_version.percentage_amount) {
          return fee_version.percentage_amount.percentage;
        }
      }
      return 'N/A';
    }
  };
})();
