module HmrcIncomeParser
  extend HmrcCostOfLiving
  extend HmrcFrequencyHelper

  def self.paye(paye_hash, average_three_months = false)
    @average_three_months = average_three_months

    sum = 0
    paye_hash.each do |i|
      next if i.blank?
      taxable = i['taxablePay']
      sum += taxable + pension(i)
    end
    total_sum(sum)
  rescue NoMethodError, TypeError
    0
  end

  def self.total_sum(sum)
    if sum.is_a?(Numeric) && sum.positive?
      return sum unless @average_three_months
      (sum / 3).round(2)
    else
      0
    end
  end

  def self.tax_credit(tax_credit_hash, request_range, average_three_months = false)
    @average_three_months = average_three_months
    sum = tax_credit_hash.sum do |i|
      payments = payments_summary(i, request_range)
      apply_child_care(payments, i)
    end

    total_sum(sum)
  rescue NoMethodError, TypeError
    0
  end

  def self.payments_summary(item, request_range)
    item['payments'].sum do |payment|
      posted_date(payment)
      tax_credit_amount(payment, request_range)
    end
  end

  def self.tax_credit_amount(payment, request_range)
    return 0 if cost_of_living_credit(payment, request_range)

    amount = format_amount(payment['amount'].to_s)
    multiplier = multiplier_per_frequency(payment, request_range)

    multiplier * amount
  end

  def self.posted_date(payment)
    @last_payment = payment.key?('postedDate') ? Date.parse(payment['postedDate']) : nil
  end

  def self.format_amount(amount)
    return 0 if amount.blank?
    return amount.to_d if amount.include?('.')
    size = amount.length
    amount.insert(size - 2, '.').to_d
  end

  def self.pension(paye_hash)
    return 0 unless paye_hash.key?('employeePensionContribs')
    paye_hash['employeePensionContribs']["paid"] || 0
  end

  def self.apply_child_care(sum, tax_hash)
    return sum if values_not_suitable(tax_hash)
    total = tax_hash['totalEntitlement'].to_f
    amount = tax_hash['childTaxCredit']['childCareAmount'].to_f

    (sum.to_f * (1 - (amount / total))).round(2)
  end

  def self.values_not_suitable(tax_hash)
    return true if tax_hash['totalEntitlement'].blank?
    return true if tax_hash['childTaxCredit'].blank? || tax_hash['childTaxCredit']['childCareAmount'].blank?
    true if tax_hash['totalEntitlement'].to_f <= 0 || tax_hash['childTaxCredit']['childCareAmount'].to_f <= 0
  end

  def self.check_tax_credit_calculation_date(tax_hash, date_range)
    return false if tax_hash.blank?
    to_date = Date.parse(date_range[:to])

    tax_hash.each do |item|
      if Date.parse(item['payProfCalcDate']) > to_date
        raise HmrcTaxCreditEntitlement,
              I18n.t('hmrc_summary.entitlement_date')
      end
    end
  rescue NoMethodError, TypeError
    false
  end
end
