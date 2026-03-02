'use strict';

window.moj.Modules.JsonSearcherModule = (function() {
  let codes = [];

  return {
    feeSelected: false,
    selectedFeeCode: null,

    init: function() {
      codes = window.moj.Modules.LoadCodesModule.getCodes();
      this.bindEvents();
    },

    getDateReceived: function() {
      const feeSearchField = $('input[id="fee_search"]');
      const dataDateReceived = feeSearchField.data('date-received');
      if (dataDateReceived) {
        return dataDateReceived;
      }
      return null;
    },

    getFeeVersionForDate: function(feeCode, dateReceived) {
      if (!dateReceived || !feeCode.fee_versions) {
        return feeCode.current_version;
      }

      const receivedDate = new Date(dateReceived);

      for (let version of feeCode.fee_versions) {
        const validFrom = new Date(version.valid_from);
        const validTo = version.valid_to ? new Date(version.valid_to) : null;
        if (receivedDate >= validFrom && (!validTo || receivedDate <= validTo)) {
          return version;
        }
      }

      return feeCode.current_version;
    },

    classifyFeeType: function(feeCode, feeVersion) {
      var hasFlatAmount = feeVersion.flat_amount && typeof feeVersion.flat_amount.amount === 'number';
      var hasPercentage = feeVersion.percentage_amount && typeof feeVersion.percentage_amount.percentage === 'number';
      var isRanged = feeCode.fee_type === 'ranged';
      var isZeroAmount = hasFlatAmount && feeVersion.flat_amount.amount === 0;

      if (isZeroAmount || feeCode.unspecified_claim_amount) {
        return 'rateable';
      }
      if (isRanged && hasPercentage) {
        return 'banded_percentage';
      }
      if (isRanged && hasFlatAmount) {
        return 'banded_flat';
      }
      return 'fixed';
    },

    bindEvents: function() {
      var self = this;
      $('input[id="fee_search"]').on('keyup', function(event){
        var searchTerm = $(event.target).val();
        self.findMatches(searchTerm);
      });

      $('input[id$="day_date_received"], input[id$="month_date_received"], input[id$="year_date_received"]').on('change blur', function() {
        var currentSearchTerm = $('input[id="fee_search"]').val();
        if (currentSearchTerm) {
          self.findMatches(currentSearchTerm);
        }
      });

      $('#calculate-percentage-fee').on('click', function() {
        self.calculateFee();
      });

      this.setFeeReadonly(true);
    },

    findMatches: function (term) {
      const dateReceived = this.getDateReceived();

      var matches = codes.filter(item => {
        const relevantVersion = this.getFeeVersionForDate(item, dateReceived);
        if (!relevantVersion) {
          return false;
        }

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
      var self = this;
      const resultsList = document.getElementById('fee-search-results');
      $('div.fee-search-results-block.govuk-inset-text').removeClass('govuk-visually-hidden');

      if (fees.length === 0) {
        $('span.search_result_count').text(0);
        resultsList.innerHTML = '';
        $('#no-results-message').removeClass('govuk-visually-hidden');
        return;
      }

      $('#no-results-message').addClass('govuk-visually-hidden');

      fees.forEach(function(fee, index) {
        if (resultsList) {
          $('span.search_result_count').text(fees.length);
          if (index === 0) resultsList.innerHTML = '';

          const li = document.createElement('li');
          const relevantVersion = self.getFeeVersionForDate(fee, dateReceived);
          const classifiedType = self.classifyFeeType(fee, relevantVersion);
          const isPercentageFee = relevantVersion.percentage_amount !== undefined;

          var displayText, feeValueText;
          if (isPercentageFee) {
            feeValueText = relevantVersion.percentage_amount.percentage + '%';
          } else {
            feeValueText = '\u00A3' + relevantVersion.flat_amount.amount;
          }
          displayText = fee.service_type.name.toUpperCase() + ' - ' + fee.code + ' - ' + feeValueText;

          const descriptionText = relevantVersion.description;
          const versionInfo = dateReceived ? ' (Valid from: ' + relevantVersion.valid_from + ')' : '';

          li.textContent = displayText + ', Description: ' + descriptionText + versionInfo;
          li.style.cursor = 'pointer';
          li.classList.add('govuk-link');

          li.setAttribute('data-fee', JSON.stringify({
            code: fee.code,
            jurisdiction1: fee.jurisdiction1,
            jurisdiction2: fee.jurisdiction2,
            event_type: fee.event_type,
            channel_type: fee.channel_type,
            service_type: fee.service_type,
            fee_version: relevantVersion,
            is_percentage: isPercentageFee,
            keyword: fee.keyword,
            fee_type: fee.fee_type,
            unspecified_claim_amount: fee.unspecified_claim_amount,
            classified_type: classifiedType
          }));

          li.addEventListener('click', function() {
            var feeData = JSON.parse(li.getAttribute('data-fee'));
            self.clearMessages();
            self.setSelectedFee(feeData, li.textContent);

            switch (feeData.classified_type) {
              case 'fixed':
                self.handleFixedFee(feeData);
                break;
              case 'banded_flat':
                self.handleBandedFee(feeData, false);
                break;
              case 'banded_percentage':
                self.handleBandedFee(feeData, true);
                break;
              case 'rateable':
                self.handleRateableFee();
                break;
            }
          });
          resultsList.appendChild(li);
        }
      });
    },

    handleFixedFee: function(feeData) {
      $('#percentage-amount-input').addClass('govuk-visually-hidden');
      this.setFeeReadonly(true);
      this.fillFeeInput({ amount: feeData.fee_version.flat_amount.amount });
    },

    handleBandedFee: function(feeData, isPercentage) {
      $('#percentage-amount-input').removeClass('govuk-visually-hidden');
      if (isPercentage) {
        $('#claim-amount-label').text('Enter the claim amount to calculate the percentage fee');
      } else {
        $('#claim-amount-label').text('Enter the claim amount to look up the fee');
      }
      $('#calculate-percentage-fee').data('fee', feeData);
      this.setFeeReadonly(true);
      $('input[id="application_fee"]').val('');
      $('#percentage_base_amount').val('').focus();
    },

    handleRateableFee: function() {
      $('#percentage-amount-input').addClass('govuk-visually-hidden');
      $('#rateable-fee-warning').removeClass('govuk-visually-hidden');
      this.setFeeReadonly(false);
      $('input[id="application_fee"]').val('').focus();
    },

    setFeeReadonly: function(readonly) {
      var feeInput = $('input[id="application_fee"]');
      if (readonly) {
        feeInput.prop('readonly', true).css({
          'background-color': '#e0e0e0',
          'color': '#000000',
          'font-weight': 'bold'
        });
      } else {
        feeInput.prop('readonly', false).css({
          'background-color': '#ffffff',
          'color': '#000000',
          'font-weight': 'normal'
        });
      }
    },

    clearMessages: function() {
      $('#band-change-warning').addClass('govuk-visually-hidden');
      $('#claim-value-error').addClass('govuk-visually-hidden');
      $('#rateable-fee-warning').addClass('govuk-visually-hidden');
      $('#no-results-message').addClass('govuk-visually-hidden');
    },

    setSelectedFee: function(feeData, displayText) {
      $('#selected-fee-text').text(displayText || feeData.code);
      $('#selected-fee-display').removeClass('govuk-visually-hidden');
      this.feeSelected = true;
      this.selectedFeeCode = feeData.code;
      $('#application_fee_code').val(feeData.code);
      $('#application_claim_amount').val('');
      $('#application_fee_version_valid_from').val(feeData.fee_version.valid_from || '');
    },

    lookupValidFrom: function(feeCode, version) {
      var match = codes.find(function(item) { return item.code === feeCode; });
      if (!match) return null;

      if (version && match.fee_versions) {
        var versionMatch = match.fee_versions.find(function(v) { return v.version === version; });
        if (versionMatch) return versionMatch.valid_from;
      }

      if (match.current_version) return match.current_version.valid_from;
      return null;
    },

    fillFeeInput: function(fee) {
      $('input[id="application_fee"]').val(fee.amount);
    },

    calculateFee: function() {
      var feeData = $('#calculate-percentage-fee').data('fee');
      var baseAmount = $('#percentage_base_amount').val();
      var self = this;

      if (!feeData) {
        $('#claim-value-error-text').text('Please select a fee first.');
        $('#claim-value-error').removeClass('govuk-visually-hidden');
        return;
      }

      if (!baseAmount || parseFloat(baseAmount) <= 0) {
        $('#claim-value-error-text').text('Please enter a valid claim amount.');
        $('#claim-value-error').removeClass('govuk-visually-hidden');
        return;
      }

      self.clearMessages();

      $.ajax({
        url: '/api/calculate_fee',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
          fee: feeData,
          base_amount: parseFloat(baseAmount)
        }),
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        success: function(response) {
          if (response.calculated_fee !== undefined && response.calculated_fee !== null) {
            self.fillFeeInput({ amount: response.calculated_fee });
            $('#application_claim_amount').val(baseAmount);

            if (response.band_changed) {
              $('#application_fee_code').val(response.fee_code);
              var newValidFrom = self.lookupValidFrom(response.fee_code, response.version);
              $('#application_fee_version_valid_from').val(newValidFrom || '');
              $('#band-change-details').text(
                ' Original fee: ' + self.selectedFeeCode +
                ', Matched fee: ' + response.fee_code +
                ' - ' + response.description
              );
              $('#band-change-warning').removeClass('govuk-visually-hidden');
              self.selectedFeeCode = response.fee_code;
              $('#selected-fee-text').text(
                response.fee_code + ' - ' + response.description +
                ' (\u00A3' + response.calculated_fee + ')'
              );
            }
          }
        },
        error: function(xhr) {
          var body = xhr.responseJSON || {};

          if (xhr.status === 404 || body.no_match) {
            $('#claim-value-error-text').text(
              'No matching fee band found for the entered claim amount. ' +
              'Please re-enter the claim amount or select a different fee.'
            );
          } else {
            $('#claim-value-error-text').text(
              'Error looking up fee. Please try again. (' + (body.error || 'Unknown error') + ')'
            );
          }
          $('#claim-value-error').removeClass('govuk-visually-hidden');
        }
      });
    }
  };
})();
