/**
 * @jest-environment jsdom
 */
'use strict';

// Fee codes covering every classifyFeeType branch plus filter edge cases.
const CODES = [
  {
    code: 'FEE100', fee_type: 'fixed',
    service_type: { name: 'civil' }, event_type: { name: 'issue' },
    jurisdiction1: { name: 'j1' }, jurisdiction2: { name: 'county court' },
    channel_type: { name: 'paper' }, keyword: 'kw', unspecified_claim_amount: false,
    current_version: { version: 'current', valid_from: '2024-01-01', flat_amount: { amount: 100 }, description: 'Fixed fee' }
  },
  {
    code: 'FEE300', fee_type: 'ranged',
    service_type: { name: 'commercial' },
    current_version: { version: 'current', valid_from: '2024-01-01', percentage_amount: { percentage: 5 }, description: 'Percentage fee' }
  },
  {
    code: 'FEE400', fee_type: 'fixed', unspecified_claim_amount: true,
    service_type: { name: 'probate' },
    current_version: { version: 'current', valid_from: '2024-01-01', flat_amount: { amount: 0 }, description: 'Rateable fee' }
  },
  {
    code: 'FEE200', fee_type: 'ranged',
    service_type: { name: 'family' },
    fee_versions: [
      { version: 'v1', valid_from: '2020-01-01', valid_to: '2022-12-31', flat_amount: { amount: 200 }, description: 'Old banded flat' },
      { version: 'v2', valid_from: '2023-01-01', flat_amount: { amount: 250 }, description: 'Banded flat' }
    ],
    current_version: { version: 'v2', valid_from: '2023-01-01', flat_amount: { amount: 250 }, description: 'Banded flat' }
  },
  // Filtered out: relevant version has no flat or percentage amount.
  {
    code: 'NOAMT', fee_type: 'fixed', service_type: { name: 'none' },
    current_version: { version: 'current', valid_from: '2024-01-01', description: 'No amount' }
  },
  // Filtered out: no version at all (getFeeVersionForDate returns undefined).
  { code: 'NOVER', service_type: { name: 'none' } }
];

function setupDom(dateReceived) {
  document.body.innerHTML = `
    <meta name="csrf-token" content="test-token">
    <form id="edit_application_1">
      <input id="fee_search" ${dateReceived ? `data-date-received="${dateReceived}"` : ''} />
      <input id="application_day_date_received" />
      <input id="application_month_date_received" />
      <input id="application_year_date_received" />
      <span class="search_result_count">0</span>
      <div class="fee-search-results-block govuk-inset-text govuk-visually-hidden">
        <ul id="fee-search-results"></ul>
        <p id="no-results-message" class="govuk-visually-hidden"></p>
      </div>
      <input id="fee_search_has_results" value="false" />
      <div id="selected-fee-display" class="govuk-visually-hidden"><span id="selected-fee-text"></span></div>
      <div id="percentage-amount-input" class="govuk-visually-hidden">
        <label id="claim-amount-label"></label>
        <input id="percentage_base_amount" />
        <button type="button" id="calculate-percentage-fee"></button>
      </div>
      <input id="application_fee" />
      <input id="application_fee_code" />
      <input id="application_claim_amount" />
      <input id="application_fee_version_valid_from" />
      <input id="application_fee_entry_method" />
      <div id="rateable-fee-warning" class="govuk-visually-hidden"></div>
      <div id="claim-value-error" class="govuk-visually-hidden"><span id="claim-value-error-text"></span></div>
    </form>
  `;
}

// The online application edit page has the date received fields on the same
// screen as the fee search, under the online_application_* ids.
function setupOnlineDom() {
  setupDom();
  $('#application_day_date_received, #application_month_date_received, #application_year_date_received').remove();
  document.getElementById('fee_search').insertAdjacentHTML('afterend', `
    <p id="date-received-required-message" class="govuk-error-message govuk-visually-hidden"></p>
    <input id="online_application_day_date_received" />
    <input id="online_application_month_date_received" />
    <input id="online_application_year_date_received" />
  `);
}

function fillOnlineDate(day, month, year) {
  $('#online_application_day_date_received').val(day);
  $('#online_application_month_date_received').val(month);
  $('#online_application_year_date_received').val(year);
}

let mod;

function loadModule() {
  jest.resetModules();
  window.moj = { Modules: { LoadCodesModule: { getCodes: () => CODES } } };
  require('../../app/javascript/freg');
  mod = window.moj.Modules.JsonSearcherModule;
}

function liFor(code) {
  return Array.from(document.querySelectorAll('#fee-search-results li'))
    .find(li => li.textContent.includes(code));
}

beforeAll(() => {
  global.$ = global.jQuery = require('jquery');
  // jsdom does not implement scrollIntoView.
  window.HTMLElement.prototype.scrollIntoView = jest.fn();
  // freg.js logs a debug line on ajax errors; keep test output clean.
  jest.spyOn(console, 'log').mockImplementation(() => {});
});

beforeEach(() => {
  setupDom();
  loadModule();
});

describe('init', () => {
  it('does nothing when there is no fee_search field', () => {
    document.body.innerHTML = '<div></div>';
    expect(() => mod.init()).not.toThrow();
    expect(mod.feeSelected).toBe(false);
  });

  it('loads codes, makes the fee field readonly and binds events', () => {
    mod.init();
    expect($('#application_fee').prop('readonly')).toBe(true);
    // codes are usable: a search now returns results
    mod.findMatches('FEE100');
    expect(liFor('FEE100')).toBeTruthy();
  });

  it('runs an existing search when the field is prefilled', () => {
    $('#fee_search').val('FEE100');
    mod.init();
    expect(liFor('FEE100')).toBeTruthy();
    expect($('#fee_search_has_results').val()).toBe('true');
  });
});

describe('getDateReceived', () => {
  it('returns the data-date-received attribute when present', () => {
    setupDom('2024-05-01');
    loadModule();
    expect(mod.getDateReceived()).toBe('2024-05-01');
  });

  it('returns null when no date is set', () => {
    expect(mod.getDateReceived()).toBeNull();
  });
});

describe('online application page', () => {
  beforeEach(() => {
    setupOnlineDom();
    loadModule();
    mod.init();
  });

  it('blocks the search and shows a message when the date received is not filled in', () => {
    mod.findMatches('FEE100');
    expect($('#date-received-required-message').hasClass('govuk-visually-hidden')).toBe(false);
    expect(liFor('FEE100')).toBeFalsy();
    expect($('span.search_result_count').text()).toBe('0');
    expect($('div.fee-search-results-block').hasClass('govuk-visually-hidden')).toBe(true);
  });

  it('blocks the search when the date received is only partially filled in', () => {
    fillOnlineDate('1', '6', '');
    mod.findMatches('FEE100');
    expect($('#date-received-required-message').hasClass('govuk-visually-hidden')).toBe(false);
    expect(liFor('FEE100')).toBeFalsy();
  });

  it('searches with the date from the fields once they are filled in', () => {
    fillOnlineDate('1', '6', '2021');
    mod.findMatches('FEE200');
    expect($('#date-received-required-message').hasClass('govuk-visually-hidden')).toBe(true);
    // 2021-06-01 falls in FEE200 v1, not the current version
    expect(liFor('FEE200').textContent).toContain('Valid from: 2020-01-01');
  });

  it('reads the live fields over the render-time data attribute', () => {
    fillOnlineDate('1', '6', '2021');
    expect(mod.getDateReceived()).toBe('2021-06-01');
  });

  it('shows results when the date is completed after a blocked search', () => {
    $('#fee_search').val('FEE100');
    $('#online_application_day_date_received').trigger('change');
    expect(liFor('FEE100')).toBeFalsy();

    fillOnlineDate('1', '6', '2024');
    $('#online_application_year_date_received').trigger('change');
    expect($('#date-received-required-message').hasClass('govuk-visually-hidden')).toBe(true);
    expect(liFor('FEE100')).toBeTruthy();
  });
});

describe('findMatches / displayFees', () => {
  beforeEach(() => mod.init());

  it('renders matching fees and flags that results exist', () => {
    mod.findMatches('FEE');
    expect($('#fee_search_has_results').val()).toBe('true');
    expect(Number($('span.search_result_count').text())).toBeGreaterThan(0);
    expect(liFor('FEE100')).toBeTruthy();
  });

  it('excludes codes with no amount or no version', () => {
    mod.findMatches('NO');
    expect(liFor('NOAMT')).toBeFalsy();
    expect(liFor('NOVER')).toBeFalsy();
    expect($('#fee_search_has_results').val()).toBe('false');
    expect($('#no-results-message').hasClass('govuk-visually-hidden')).toBe(false);
  });

  it('matches on the fee amount as well as the code', () => {
    mod.findMatches('100');
    expect(liFor('FEE100')).toBeTruthy();
  });

  it('includes the valid_from note when a date received is set', () => {
    setupDom('2024-06-01');
    loadModule();
    mod.init();
    mod.findMatches('FEE100');
    expect(liFor('FEE100').textContent).toContain('Valid from:');
  });
});

describe('selecting a fee (click) routes by classified type', () => {
  beforeEach(() => mod.init());

  it('fixed fee fills the fee input and sets auto entry method', () => {
    mod.findMatches('FEE100');
    liFor('FEE100').click();
    expect($('#application_fee').val()).toBe('100');
    expect($('#application_fee_entry_method').val()).toBe('auto');
    expect($('#application_fee').prop('readonly')).toBe(true);
  });

  it('banded flat fee fills the fee input and sets auto entry method', () => {
    mod.findMatches('FEE200');
    liFor('FEE200').click();
    expect($('#application_fee').val()).toBe('250');
    expect($('#application_fee_entry_method').val()).toBe('auto');
  });

  it('banded percentage fee reveals the percentage input', () => {
    mod.findMatches('FEE300');
    liFor('FEE300').click();
    expect($('#percentage-amount-input').hasClass('govuk-visually-hidden')).toBe(false);
    expect($('#application_fee_entry_method').val()).toBe('auto');
  });

  it('rateable fee makes the fee input editable and sets manual entry', () => {
    mod.findMatches('FEE400');
    liFor('FEE400').click();
    expect($('#application_fee').prop('readonly')).toBe(false);
    expect($('#application_fee_entry_method').val()).toBe('manual');
    expect($('#rateable-fee-warning').hasClass('govuk-visually-hidden')).toBe(false);
  });
});

describe('resetSelection', () => {
  it('clears the selected fee and hidden fields', () => {
    $('#application_fee_code').val('FEE100');
    $('#application_fee').val('100');
    mod.feeSelected = true;
    mod.resetSelection();
    expect(mod.feeSelected).toBe(false);
    expect(mod.selectedFeeCode).toBeNull();
    expect($('#application_fee_code').val()).toBe('');
    expect($('#application_fee').val()).toBe('');
    expect($('#application_fee').prop('readonly')).toBe(true);
  });
});

describe('setFeeReadonly', () => {
  it('toggles the readonly property', () => {
    mod.setFeeReadonly(false);
    expect($('#application_fee').prop('readonly')).toBe(false);
    mod.setFeeReadonly(true);
    expect($('#application_fee').prop('readonly')).toBe(true);
  });
});

describe('setSelectedFee', () => {
  it('records the fee and shows the selected-fee display', () => {
    mod.setSelectedFee({ code: 'FEE100', fee_version: { valid_from: '2024-01-01' } }, 'CIVIL - FEE100');
    expect(mod.feeSelected).toBe(true);
    expect(mod.selectedFeeCode).toBe('FEE100');
    expect($('#selected-fee-text').text()).toBe('CIVIL - FEE100');
    expect($('#selected-fee-display').hasClass('govuk-visually-hidden')).toBe(false);
    expect($('#application_fee_version_valid_from').val()).toBe('2024-01-01');
  });

  it('falls back to the code when no display text is given', () => {
    mod.setSelectedFee({ code: 'FEE100', fee_version: {} }, null);
    expect($('#selected-fee-text').text()).toBe('FEE100');
  });
});

describe('handleBandedFee', () => {
  it('uses the look-up label when it is not a percentage fee', () => {
    mod.handleBandedFee({ code: 'FEE200' }, false);
    expect($('#claim-amount-label').text()).toContain('look up the fee');
  });
});

describe('lookupValidFrom', () => {
  beforeEach(() => mod.init());

  it('returns the matching version valid_from', () => {
    expect(mod.lookupValidFrom('FEE200', 'v1')).toBe('2020-01-01');
  });

  it('falls back to current_version when the version is not found', () => {
    expect(mod.lookupValidFrom('FEE100', 'missing')).toBe('2024-01-01');
  });

  it('returns null when the code exists but has no current_version', () => {
    expect(mod.lookupValidFrom('NOVER', 'v1')).toBeNull();
  });

  it('returns null when the code is unknown', () => {
    expect(mod.lookupValidFrom('UNKNOWN', 'v1')).toBeNull();
  });
});

describe('clearMessages', () => {
  it('hides errors and removes an empty error summary', () => {
    document.body.insertAdjacentHTML('beforeend',
      '<div role="alert"><ul class="govuk-error-summary__list"></ul></div>');
    $('#claim-value-error').removeClass('govuk-visually-hidden');
    mod.clearMessages();
    expect($('#claim-value-error').hasClass('govuk-visually-hidden')).toBe(true);
    expect($('[role="alert"]').length).toBe(0);
  });
});

describe('showBandChangeError', () => {
  it('creates an error summary when none exists', () => {
    mod.showBandChangeError();
    expect($('.band-change-error-item').length).toBe(1);
    expect($('.govuk-error-summary').length).toBe(1);
    expect(window.HTMLElement.prototype.scrollIntoView).toHaveBeenCalled();
  });

  it('appends to an existing error summary', () => {
    $('form').before(
      '<div class="govuk-error-summary"><ul class="govuk-error-summary__list"></ul></div>');
    mod.showBandChangeError();
    expect($('.govuk-error-summary').length).toBe(1);
    expect($('.band-change-error-item').length).toBe(1);
  });
});

describe('calculateFee', () => {
  const feeData = { code: 'FEE300', fee_version: { percentage_amount: { percentage: 5 } } };

  function selectPercentageFee() {
    $('#calculate-percentage-fee').data('fee', feeData);
  }

  it('shows an error when no fee is selected', () => {
    mod.calculateFee();
    expect($('#claim-value-error-text').text()).toContain('select a fee first');
    expect($('#claim-value-error').hasClass('govuk-visually-hidden')).toBe(false);
  });

  it('shows an error when the claim amount is invalid', () => {
    selectPercentageFee();
    $('#percentage_base_amount').val('0');
    mod.calculateFee();
    expect($('#claim-value-error-text').text()).toContain('valid claim amount');
  });

  it('fills the fee on a successful calculation', () => {
    selectPercentageFee();
    mod.originalFeeCode = 'FEE300';
    mod.originalDisplayText = 'COMMERCIAL - FEE300';
    $('#percentage_base_amount').val('1000');
    $.ajax = jest.fn(opts => opts.success({ calculated_fee: 50, band_changed: false }));

    mod.calculateFee();

    expect($('#application_fee').val()).toBe('50');
    expect($('#application_claim_amount').val()).toBe('1000');
    expect($('#application_fee_entry_method').val()).toBe('auto');
  });

  it('shows the band-change error when the band changed', () => {
    selectPercentageFee();
    $('#percentage_base_amount').val('1000');
    $.ajax = jest.fn(opts => opts.success({ calculated_fee: 50, band_changed: true }));

    mod.calculateFee();

    expect($('#application_fee').val()).toBe('');
    expect($('.band-change-error-item').length).toBe(1);
  });

  it('shows a not-found message on a 404 response', () => {
    selectPercentageFee();
    $('#percentage_base_amount').val('1000');
    $.ajax = jest.fn(opts => opts.error({ status: 404, responseJSON: {} }));

    mod.calculateFee();

    expect($('#claim-value-error-text').text()).toContain('No court or tribunal fee found');
  });

  it('shows a generic message on other errors', () => {
    selectPercentageFee();
    $('#percentage_base_amount').val('1000');
    $.ajax = jest.fn(opts => opts.error({ status: 500, responseJSON: { error: 'boom' } }));

    mod.calculateFee();

    expect($('#claim-value-error-text').text()).toContain('boom');
  });

  it('falls back to "Unknown error" when the error has no body', () => {
    selectPercentageFee();
    $('#percentage_base_amount').val('1000');
    $.ajax = jest.fn(opts => opts.error({ status: 500 }));

    mod.calculateFee();

    expect($('#claim-value-error-text').text()).toContain('Unknown error');
  });
});

describe('bound events', () => {
  beforeEach(() => mod.init());

  it('re-searches on keyup when the term is long enough', () => {
    $('#fee_search').val('FEE100').trigger($.Event('keyup', { key: 'a' }));
    expect(liFor('FEE100')).toBeTruthy();
  });

  it('resets and hides results on keyup when the term is too short', () => {
    mod.findMatches('FEE100');
    $('#fee_search').val('F').trigger($.Event('keyup', { key: 'Backspace' }));
    expect($('span.search_result_count').text()).toBe('0');
    expect($('div.fee-search-results-block').hasClass('govuk-visually-hidden')).toBe(true);
  });

  it('ignores modifier keys on keyup', () => {
    $('#fee_search').val('FEE100').trigger($.Event('keyup', { key: 'Shift' }));
    expect(liFor('FEE100')).toBeFalsy();
  });

  it('re-searches when the date fields change and no fee is selected', () => {
    $('#fee_search').val('FEE100');
    $('#application_day_date_received').trigger('change');
    expect(liFor('FEE100')).toBeTruthy();
  });

  it('keeps the selected fee when the date changes after selection', () => {
    mod.feeSelected = true;
    $('#fee_search').val('FEE100');
    $('#application_day_date_received').trigger('change');
    expect(liFor('FEE100')).toBeFalsy();
  });

  it('does not search on date change when the term is too short', () => {
    $('#fee_search').val('F');
    $('#application_day_date_received').trigger('change');
    expect(liFor('FEE100')).toBeFalsy();
  });

  it('calculates the fee when the calculate button is clicked', () => {
    $('#calculate-percentage-fee').trigger('click');
    expect($('#claim-value-error-text').text()).toContain('select a fee first');
  });
});
