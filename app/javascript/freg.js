'use strict';

const FregHelpers = require('./freg_helpers');

window.moj.Modules.JsonSearcherModule = (function() {
  let codes = [];

  function dateFromFields(day, month, year) {
    if (!day || !month || !year) return null;
    return year + '-' + String(month).padStart(2, '0') + '-' + String(day).padStart(2, '0');
  }

  return {
    feeSelected: false,
    selectedFeeCode: null,
    originalFeeCode: null,
    originalDisplayText: null,

    init: function() {
      if ($('input[id="fee_search"]').length === 0) return;

      codes = window.moj.Modules.LoadCodesModule.getCodes();
      this.bindEvents();

      var existingSearch = $('input[id="fee_search"]').val();
      if (existingSearch && existingSearch.length >= 2) {
        this.findMatches(existingSearch);
      }
    },

    getDateReceived: function() {
      // The online application page has the date received fields on the same
      // screen, so read them live - the data attribute is stamped at render
      // time and would be blank until the form is saved.
      if (this.isOnlineApplicationPage()) {
        return this.onlineDateReceived();
      }
      const feeSearchField = $('input[id="fee_search"]');
      const dataDateReceived = feeSearchField.data('date-received');
      if (dataDateReceived) {
        return dataDateReceived;
      }
      return null;
    },

    isOnlineApplicationPage: function() {
      return $('input[id="online_application_day_date_received"]').length > 0;
    },

    onlineDateReceived: function() {
      return dateFromFields(
        $('input[id="online_application_day_date_received"]').val(),
        $('input[id="online_application_month_date_received"]').val(),
        $('input[id="online_application_year_date_received"]').val()
      );
    },

    isRefundApplication: function() {
      // The pre-UCD paper details page has the refund checkbox on the same
      // screen, so read it live. On other pages the flag is stamped on the
      // fee search field at render time.
      const refundCheckbox = $('input[id="application_refund"]');
      if (refundCheckbox.length > 0) {
        return refundCheckbox.is(':checked');
      }
      return String($('input[id="fee_search"]').data('refund')) === 'true';
    },

    getDateFeePaid: function() {
      const dayField = $('input[id="application_day_date_fee_paid"]');
      if (dayField.length > 0) {
        return dateFromFields(
          dayField.val(),
          $('input[id="application_month_date_fee_paid"]').val(),
          $('input[id="application_year_date_fee_paid"]').val()
        );
      }
      return $('input[id="fee_search"]').data('date-fee-paid') || null;
    },

    bindEvents: function() {
      var self = this;
      $('input[id="fee_search"]').on('keyup', function(event){
        if (event.key === 'Tab' || event.key === 'Shift' || event.key === 'Control' ||
            event.key === 'Alt' || event.key === 'Meta') return;
        var searchTerm = $(event.target).val();
        if (searchTerm.length < 2) {
          self.resetSelection();
          $('span.search_result_count').text(0);
          $('div.fee-search-results-block.govuk-inset-text').addClass('govuk-visually-hidden');
          return;
        }
        self.findMatches(searchTerm);
      });

      $('input[id$="day_date_received"], input[id$="month_date_received"], input[id$="year_date_received"]').on('change blur', function() {
        // On the online application page the search date comes from these
        // fields, so changing them resets the search and any selected fee.
        // On the paper page the search date is fixed at render time, so
        // preserve the fee the user picked.
        if (self.feeSelected) {
          if (!self.isOnlineApplicationPage()) return;
          self.resetSelection();
        }
        var currentSearchTerm = $('input[id="fee_search"]').val();
        if (currentSearchTerm && currentSearchTerm.length >= 2) {
          self.findMatches(currentSearchTerm);
        }
      });

      $('input[id="application_refund"], input[id$="_date_fee_paid"]').on('change blur', function() {
        // Pre-UCD paper page only: the refund checkbox and date fee paid
        // fields live on the same screen and drive the search date, so
        // changing them invalidates any selected fee.
        if (self.feeSelected) {
          self.resetSelection();
        }
        var currentSearchTerm = $('input[id="fee_search"]').val();
        if (currentSearchTerm && currentSearchTerm.length >= 2) {
          self.findMatches(currentSearchTerm);
        }
      });

      $('#calculate-percentage-fee').on('click', function() {
        self.calculateFee();
      });

      this.setFeeReadonly(true);
    },

    resetSelection: function() {
      this.feeSelected = false;
      this.selectedFeeCode = null;
      this.originalFeeCode = null;
      this.originalDisplayText = null;
      this.clearMessages();
      $('#selected-fee-display').addClass('govuk-visually-hidden');
      $('#percentage-amount-input').addClass('govuk-visually-hidden');
      $('#application_fee_code').val('');
      $('#application_claim_amount').val('');
      $('#application_fee_version_valid_from').val('');
      $('#application_fee_entry_method').val('');
      $('#fee_search_has_results').val('false');
      $('input[id="application_fee"]').val('');
      $('#percentage_base_amount').val('');
      $('#calculate-percentage-fee').removeData('fee');
      this.setFeeReadonly(true);
    },

    findMatches: function (term) {
      this.resetSelection();
      const dateReceived = this.getDateReceived();

      if (this.isOnlineApplicationPage() && !dateReceived) {
        this.showDateReceivedRequired();
        return;
      }

      // A refund is for a fee that was already paid, so the amount comes from
      // the version in force on the date the fee was paid, not the date the
      // application was received.
      const refundDate = this.isRefundApplication() ? this.getDateFeePaid() : null;
      const searchDate = refundDate || dateReceived;
      let feeDroppedForRefundDate = false;

      var matches = codes.filter(item => {
        const relevantVersion = FregHelpers.getFeeVersionForDate(item, searchDate);
        if (!relevantVersion) {
          return false;
        }

        const hasFlatAmount = relevantVersion.flat_amount && typeof relevantVersion.flat_amount.amount === 'number';
        const hasPercentage = relevantVersion.percentage_amount && typeof relevantVersion.percentage_amount.percentage === 'number';

        if (!hasFlatAmount && !hasPercentage) {
          return false;
        }

        const matchesTerm = (
          (item.code && item.code.toLowerCase().includes(term.toLowerCase())) ||
          (item.jurisdiction2 && item.jurisdiction2.name && item.jurisdiction2.name.toLowerCase().includes(term.toLowerCase())) ||
          (hasFlatAmount && relevantVersion.flat_amount.amount.toString().includes(term)) ||
          (hasPercentage && relevantVersion.percentage_amount.percentage.toString().includes(term)) ||
          (item.event_type && item.event_type.name && item.event_type.name.toLowerCase().includes(term.toLowerCase())) ||
          (item.service_type && item.service_type.name && item.service_type.name.toLowerCase().includes(term.toLowerCase())) ||
          (relevantVersion && relevantVersion.description && relevantVersion.description.toLowerCase().includes(term.toLowerCase()))
        );
        if (!matchesTerm) {
          return false;
        }

        // For refunds there is no fallback to the current version: if no
        // version covers the date the fee was paid, the fee cannot be
        // offered. Rateable fees stay because their amount is entered
        // manually, not read from FREG.
        if (refundDate && !FregHelpers.findFeeVersionForDate(item, refundDate) &&
            FregHelpers.classifyFeeType(item, relevantVersion) !== 'rateable') {
          feeDroppedForRefundDate = true;
          return false;
        }

        return true;
      });

      matches.sort(function(a, b) {
        return (a.code || '').localeCompare(b.code || '');
      });

      this.displayFees(matches, searchDate, feeDroppedForRefundDate);
    },

    displayFees: function (fees, searchDate, feeDroppedForRefundDate) {
      var self = this;
      const resultsList = document.getElementById('fee-search-results');
      $('div.fee-search-results-block.govuk-inset-text').removeClass('govuk-visually-hidden');

      if (fees.length === 0) {
        $('span.search_result_count').text(0);
        resultsList.innerHTML = '';
        $('#fee_search_has_results').val('false');
        if (feeDroppedForRefundDate) {
          $('#fee-date-not-found-message').removeClass('govuk-visually-hidden');
        } else {
          $('#no-results-message').removeClass('govuk-visually-hidden');
        }
        return;
      }

      $('#fee_search_has_results').val('true');
      $('#no-results-message').addClass('govuk-visually-hidden');

      fees.forEach(function(fee, index) {
        if (resultsList) {
          $('span.search_result_count').text(fees.length);
          if (index === 0) resultsList.innerHTML = '';

          const li = document.createElement('li');
          const relevantVersion = FregHelpers.getFeeVersionForDate(fee, searchDate);
          const classifiedType = FregHelpers.classifyFeeType(fee, relevantVersion);
          const isPercentageFee = relevantVersion.percentage_amount !== undefined;

          var displayText, feeValueText;
          if (isPercentageFee) {
            feeValueText = relevantVersion.percentage_amount.percentage + '%';
          } else {
            feeValueText = '\u00A3' + relevantVersion.flat_amount.amount;
          }
          displayText = fee.service_type.name.toUpperCase() + ' - ' + fee.code + ' - ' + feeValueText;

          const descriptionText = relevantVersion.description;
          const versionInfo = searchDate ? ' (Valid from: ' + relevantVersion.valid_from + ')' : '';

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
                $('#application_fee_entry_method').val('auto');
                break;
              case 'banded_flat':
                self.handleFixedFee(feeData);
                $('#application_fee_entry_method').val('auto');
                break;
              case 'banded_percentage':
                self.handleBandedFee(feeData, true);
                $('#application_fee_entry_method').val('auto');
                break;
              case 'rateable':
                self.handleRateableFee();
                $('#application_fee_entry_method').val('manual');
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

    showDateReceivedRequired: function() {
      $('span.search_result_count').text(0);
      $('div.fee-search-results-block.govuk-inset-text').addClass('govuk-visually-hidden');
      $('#date-received-required-message').removeClass('govuk-visually-hidden');
    },

    clearMessages: function() {
      $('#date-received-required-message').addClass('govuk-visually-hidden');
      $('#claim-value-error').addClass('govuk-visually-hidden');
      $('#rateable-fee-warning').addClass('govuk-visually-hidden');
      $('#no-results-message').addClass('govuk-visually-hidden');
      $('#fee-date-not-found-message').addClass('govuk-visually-hidden');
      $('.band-change-error-item').remove();
      var summaryList = $('.govuk-error-summary__list');
      if (summaryList.length && summaryList.children().length === 0) {
        summaryList.closest('[role="alert"]').remove();
      }
    },

    showBandChangeError: function() {
      $('.band-change-error-item').remove();
      var errorItem = '<li class="band-change-error-item">' +
        'The claim amount falls in a different fee band. ' +
        'Enter another claim amount or search for/select another fee code.</li>';

      var existingSummary = $('.govuk-error-summary');
      if (existingSummary.length) {
        existingSummary.find('.govuk-error-summary__list').append(errorItem);
      } else {
        var errorHtml = '<div role="alert">' +
          '<div class="govuk-error-summary" tabindex="-1" data-module="govuk-error-summary">' +
          '<h2 class="govuk-error-summary__title">There is a problem</h2>' +
          '<div class="govuk-error-summary__body">' +
          '<ul class="govuk-list govuk-error-summary__list">' +
          errorItem +
          '</ul></div></div></div>';
        var form = $('form[id^="edit_"], form.new_application, form').first();
        form.before(errorHtml);
      }
      var summary = $('.govuk-error-summary')[0];
      summary.scrollIntoView({ behavior: 'smooth' });
      summary.focus();
    },

    setSelectedFee: function(feeData, displayText) {
      $('#selected-fee-text').text(displayText || feeData.code);
      $('#selected-fee-display').removeClass('govuk-visually-hidden');
      this.feeSelected = true;
      this.selectedFeeCode = feeData.code;
      this.originalFeeCode = feeData.code;
      this.originalDisplayText = displayText || feeData.code;
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
            if (response.band_changed) {
              $('input[id="application_fee"]').val('');
              self.showBandChangeError();
            } else {
              self.fillFeeInput({ amount: response.calculated_fee });
              $('#application_claim_amount').val(baseAmount);
              self.selectedFeeCode = self.originalFeeCode;
              $('#application_fee_code').val(self.originalFeeCode);
              $('#application_fee_entry_method').val('auto');
              $('#selected-fee-text').text(self.originalDisplayText);
            }
          }
        },
        error: function(xhr) {
          console.log('Calculate fee error:', xhr.status, xhr.responseJSON);
          var body = xhr.responseJSON || {};

          var errorMessage;
          if (xhr.status === 404 || body.no_match) {
            errorMessage = 'No court or tribunal fee found for the claim amount. ' +
              'Enter another claim amount.';
          } else {
            errorMessage = 'Error looking up fee. Please try again. (' + (body.error || 'Unknown error') + ')';
          }
          $('#claim-value-error-text').text(errorMessage);
          $('#claim-value-error').removeClass('govuk-visually-hidden');
        }
      });
    }
  };
})();
