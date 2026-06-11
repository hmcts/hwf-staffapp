'use strict';

function getFeeVersionForDate(feeCode, dateReceived) {
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

module.exports = { getFeeVersionForDate, classifyFeeType };
