'use strict';

// Strict lookup: returns the version whose valid_from/valid_to range covers
// the date, or null when none does. Used for refunds, where falling back to
// the current version would quote the wrong (current) fee amount.
function findFeeVersionForDate(feeCode, date) {
  if (!date) return null;

  const versions = feeCode.fee_versions ||
    (feeCode.current_version ? [feeCode.current_version] : []);
  const targetDate = new Date(date);

  for (let version of versions) {
    const validFrom = new Date(version.valid_from);
    const validTo = version.valid_to ? new Date(version.valid_to) : null;
    if (targetDate >= validFrom && (!validTo || targetDate <= validTo)) {
      return version;
    }
  }

  return null;
}

function getFeeVersionForDate(feeCode, date) {
  return findFeeVersionForDate(feeCode, date) || feeCode.current_version;
}

function classifyFeeType(feeCode, feeVersion) {
  const hasFlatAmount = feeVersion.flat_amount && typeof feeVersion.flat_amount.amount === 'number';
  const hasPercentage = feeVersion.percentage_amount && typeof feeVersion.percentage_amount.percentage === 'number';
  const isRanged = feeCode.fee_type === 'ranged';
  const isZeroAmount = hasFlatAmount && feeVersion.flat_amount.amount === 0;

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
}

module.exports = { getFeeVersionForDate, findFeeVersionForDate, classifyFeeType };
