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

    getDateReceived: function() {
      // First try to get date from the data attribute (for details page)
      const feeSearchField = $('input[id="fee_search"]');
      const dataDateReceived = feeSearchField.data('date-received');
      console.log('Data date received:', dataDateReceived);
      if (dataDateReceived) {
        return dataDateReceived;
      }

      return null;
    },

    // The search function to find fee would not work for old fees so if they are looking for 31 but the date_received
    // is 30/06/2025 but the fee valid for this timeframe is 30 then the searach will fail.

    getFeeVersionForDate: function(feeCode, dateReceived) {
      if (!dateReceived || !feeCode.fee_versions) {
        return feeCode.current_version;
      }

      const receivedDate = new Date(dateReceived);

      // Find the version that was valid on the date received
      for (let version of feeCode.fee_versions) {
        const validFrom = new Date(version.valid_from);
        const validTo = version.valid_to ? new Date(version.valid_to) : null;
        // Check if the received date falls within the valid period
        if (receivedDate >= validFrom && (!validTo || receivedDate <= validTo)) {
          return version;
        }
      }


      // Fallback to current version if no match found
      return feeCode.current_version;
    },

    bindEvents: function() {
      var self = this;
      $('input[id="fee_search"]').on('keyup', function(event){
        var searchTerm = $(event.target).val();
        self.findMatches(searchTerm);
      });

      // Re-run search when date received fields change
      $('input[id$="day_date_received"], input[id$="month_date_received"], input[id$="year_date_received"]').on('change blur', function() {
        var currentSearchTerm = $('input[id="fee_search"]').val();
        if (currentSearchTerm) {
          self.findMatches(currentSearchTerm);
        }
      });

      // Bind calculate percentage fee button
      $('#calculate-percentage-fee').on('click', function() {
        self.calculatePercentageFee();
      });

      $('#application_fee')
        .prop('disabled', true)
        .attr('aria-disabled', 'true')
        .css({
          'background-color': '#e0e0e0',
          'color': '#000000',
          'font-weight': 'bold'
        })

    },

    // Updated search function to use date-based fee version selection
    findMatches: function (term) {
      const dateReceived = this.getDateReceived();

      var matches = codes.filter(item => {
        // Get the correct fee version based on date received
        const relevantVersion = this.getFeeVersionForDate(item, dateReceived);
        if (!relevantVersion) {
          return false;
        }

        // Check if it's a flat amount or percentage fee
        const hasFlatAmount = relevantVersion.flat_amount && typeof relevantVersion.flat_amount.amount === 'number';
        const hasPercentage = relevantVersion.percentage_amount && typeof relevantVersion.percentage_amount.percentage === 'number';

        if (!hasFlatAmount && !hasPercentage) {
          return false;
        }

        return (
          (item.code && item.code.toLowerCase().includes(term.toLowerCase())) ||
          (item.jurisdiction2 && item.jurisdiction2.name && item.jurisdiction2.name.toLowerCase().includes(term.toLowerCase())) ||
          (hasFlatAmount && relevantVersion.flat_amount.amount.toString().includes(term)) ||
          (hasPercentage && relevantVersion.percentage_amount.percentage.toString().includes(term)) ||
          (item.event_type && item.event_type.name && item.event_type.name.toLowerCase().includes(term.toLowerCase())) ||
          (item.service_type && item.service_type.name && item.service_type.name.toLowerCase().includes(term.toLowerCase())) ||
          (relevantVersion && relevantVersion.description && relevantVersion.description.toLowerCase().includes(term.toLowerCase()))
        );
      });

      this.displayFees(matches, dateReceived);
    },

    displayFees: function (fees, dateReceived) {
      const resultsList = document.getElementById('fee-search-results');
      $('div.fee-search-results-block.govuk-inset-text').removeClass('govuk-visually-hidden');
      fees.forEach(fee => {
        if (resultsList) {
          $('span.search_result_count').text(fees.length)
          if (fee === fees[0]) resultsList.innerHTML = ''; // Clear only once at the start
            const li = document.createElement('li');

            // Get the correct fee version based on date received
            const relevantVersion = this.getFeeVersionForDate(fee, dateReceived);

            // Check if it's a percentage or flat amount fee
            const isPercentageFee = relevantVersion.percentage_amount !== undefined;

            let displayText, feeValueText;
            if (isPercentageFee) {
              feeValueText = `${relevantVersion.percentage_amount.percentage}%`;
              displayText = `${fee.service_type.name.toUpperCase()} - ${fee.code} - ${feeValueText}`;
            } else {
              feeValueText = `£${relevantVersion.flat_amount.amount}`;
              displayText = `${fee.service_type.name.toUpperCase()} - ${fee.code} - ${feeValueText}`;
            }

            const descriptionText = relevantVersion.description;
            const versionInfo = dateReceived ? ` (Valid from: ${relevantVersion.valid_from})` : '';

            li.textContent = `${displayText}, Description: ${descriptionText}${versionInfo}`;
            li.style.cursor = 'pointer';
            li.classList.add('govuk-link');

            // Store complete fee data for later use
            li.setAttribute('data-fee', JSON.stringify({
              code: fee.code,
              jurisdiction1: fee.jurisdiction1,
              jurisdiction2: fee.jurisdiction2,
              event_type: fee.event_type,
              channel_type: fee.channel_type,
              service_type: fee.service_type,
              fee_version: relevantVersion,
              is_percentage: isPercentageFee,
              keyword: fee.keyword
            }));

            li.addEventListener('click', () => {
              const feeData = JSON.parse(li.getAttribute('data-fee'));
              if (feeData.is_percentage) {
                // Show percentage input field
                $('#percentage-amount-input').removeClass('govuk-visually-hidden');
                // Store fee data for calculation
                $('#calculate-percentage-fee').data('fee', feeData);
              } else {
                // Hide percentage input field and fill regular fee input
                $('#percentage-amount-input').addClass('govuk-visually-hidden');
                window.moj.Modules.JsonSearcherModule.fillFeeInput({ amount: relevantVersion.flat_amount.amount });
              }
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

    calculatePercentageFee: function() {
      const feeData = $('#calculate-percentage-fee').data('fee');
      const baseAmount = $('#percentage_base_amount').val();

      if (!feeData) {
        alert('Please select a percentage fee first');
        return;
      }

      if (!baseAmount || parseFloat(baseAmount) <= 0) {
        alert('Please enter a valid amount');
        return;
      }

      // Call the API with complete fee object
      $.ajax({
        url: '/api/calculate_percentage_fee',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
          fee: feeData,
          base_amount: parseFloat(baseAmount),
          use_api: false  // Set to true to use external FREG API, false for local calculation
        }),
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        success: function(response) {
          // TODO: Handle the response and populate the fee field
          // For now, just log the response
          console.log('Fee calculation response:', response);
          if (response.calculated_fee) {
            window.moj.Modules.JsonSearcherModule.fillFeeInput({ amount: response.calculated_fee });
            // $('#percentage-amount-input').addClass('govuk-visually-hidden');
          }
        },
        error: function(xhr, status, error) {
          console.error('Error calculating fee:', error);
          alert('Error calculating fee. Please try again.');
        }
      });
    },
  };
})();
