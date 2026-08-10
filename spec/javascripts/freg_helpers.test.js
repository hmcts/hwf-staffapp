'use strict';

const { getFeeVersionForDate, findFeeVersionForDate, classifyFeeType } = require('../../app/javascript/freg_helpers');

describe('getFeeVersionForDate', () => {
  const feeCode = {
    current_version: { version: 'current', valid_from: '2024-01-01' },
    fee_versions: [
      { version: 'v1', valid_from: '2020-01-01', valid_to: '2022-12-31' },
      { version: 'v2', valid_from: '2023-01-01', valid_to: '2024-12-31' },
      { version: 'v3', valid_from: '2025-01-01' }
    ]
  };

  test('returns the current_version when dateReceived is missing', () => {
    expect(getFeeVersionForDate(feeCode, null)).toEqual(feeCode.current_version);
  });

  test('returns the current_version when fee has no fee_versions list', () => {
    const noVersions = { current_version: feeCode.current_version };
    expect(getFeeVersionForDate(noVersions, '2024-06-01')).toEqual(noVersions.current_version);
  });

  test('returns the version whose [valid_from, valid_to] range covers the received date', () => {
    expect(getFeeVersionForDate(feeCode, '2024-06-01').version).toBe('v2');
  });

  test('matches an open-ended version (no valid_to) for dates on or after its valid_from', () => {
    expect(getFeeVersionForDate(feeCode, '2026-03-15').version).toBe('v3');
  });

  test('falls back to current_version when no version matches the date', () => {
    expect(getFeeVersionForDate(feeCode, '1999-01-01')).toEqual(feeCode.current_version);
  });
});

describe('findFeeVersionForDate', () => {
  const feeCode = {
    current_version: { version: 'current', valid_from: '2024-01-01' },
    fee_versions: [
      { version: 'v1', valid_from: '2020-01-01', valid_to: '2022-12-31' },
      { version: 'v2', valid_from: '2023-01-01', valid_to: '2024-12-31' }
    ]
  };

  test('returns null when the date is missing', () => {
    expect(findFeeVersionForDate(feeCode, null)).toBeNull();
  });

  test('returns the version whose range covers the date', () => {
    expect(findFeeVersionForDate(feeCode, '2021-06-01').version).toBe('v1');
  });

  test('returns null when no version covers the date - no fallback', () => {
    expect(findFeeVersionForDate(feeCode, '2019-01-01')).toBeNull();
  });

  test('checks the current_version range when the fee has no fee_versions list', () => {
    const noVersions = { current_version: { version: 'current', valid_from: '2024-01-01' } };
    expect(findFeeVersionForDate(noVersions, '2024-06-01').version).toBe('current');
    expect(findFeeVersionForDate(noVersions, '2023-06-01')).toBeNull();
  });

  test('returns null when the fee has no versions at all', () => {
    expect(findFeeVersionForDate({}, '2024-06-01')).toBeNull();
  });
});

describe('classifyFeeType', () => {
  test('returns "fixed" when the version has a non-zero flat_amount and the fee is not ranged', () => {
    const feeCode = { fee_type: 'fixed' };
    const feeVersion = { flat_amount: { amount: 100 } };
    expect(classifyFeeType(feeCode, feeVersion)).toBe('fixed');
  });

  test('returns "banded_flat" when the fee is ranged and the version has a flat_amount', () => {
    const feeCode = { fee_type: 'ranged' };
    const feeVersion = { flat_amount: { amount: 250 } };
    expect(classifyFeeType(feeCode, feeVersion)).toBe('banded_flat');
  });

  test('returns "banded_percentage" when the fee is ranged and the version has a percentage_amount', () => {
    const feeCode = { fee_type: 'ranged' };
    const feeVersion = { percentage_amount: { percentage: 5 } };
    expect(classifyFeeType(feeCode, feeVersion)).toBe('banded_percentage');
  });

  test('returns "rateable" when flat_amount is zero', () => {
    const feeCode = { fee_type: 'fixed' };
    const feeVersion = { flat_amount: { amount: 0 } };
    expect(classifyFeeType(feeCode, feeVersion)).toBe('rateable');
  });

  test('returns "rateable" when the fee is flagged as unspecified_claim_amount', () => {
    const feeCode = { fee_type: 'fixed', unspecified_claim_amount: true };
    const feeVersion = { flat_amount: { amount: 100 } };
    expect(classifyFeeType(feeCode, feeVersion)).toBe('rateable');
  });
});
