module HmrcIncomeParser

  def self.paye(paye_hash)
    sum = paye_hash.sum do |i|
      taxable = i['taxablePay']
      taxable + pension(i)
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end

  def self.tax_credit(tax_credit_hash, request_range)
    sum = tax_credit_hash.sum do |i|
      payments = i['payments'].sum do |payment|
        tax_credit_amount(payment, request_range)
      end
      apply_child_care(payments, i)
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end

  def self.tax_credit_amount(payment, request_range)
    return 0 if cost_of_living_credit(payment, request_range)
    amount = format_amount(payment['amount'].to_s)
    multiplier = multiplier_per_frequency(payment, request_range)
    multiplier * amount
  end

  def self.format_amount(amount)
    return 0 if amount.blank?
    return amount.to_d if amount.include?('.')
    size = amount.length
    amount.insert(size - 2, '.').to_d
  end

  def self.multiplier_per_frequency(payment, request_range)
    return payment['frequency'] if payment['frequency'] == 1

    from = Date.parse(request_range[:from])
    to = Date.parse(request_range[:to])
    end_date = Date.parse(payment['endDate'])
    start_date = Date.parse(payment['startDate'])

    list = frequency_days(start_date, end_date, payment['frequency'])

    list.count { |day_iteration| day_iteration >= from && day_iteration <= to }
  end

  def self.frequency_days(day, end_date, frequency)
    return if frequency.zero?
    list = []

    while day < end_date
      day += frequency
      list << day
    end
    list
  end

  def self.pension(paye_hash)
    return 0 unless paye_hash.key?('employeePensionContribs')
    paye_hash['employeePensionContribs']["paid"] || 0
  end

  # RST-4697 for more info
  def self.cost_of_living_credit(payment, request_range)
    if request_range[:from] == "2022-09-01" && request_range[:to] == "2022-09-30"
      return true if payment['amount'].to_i == 326
    elsif request_range[:from] == "2022-11-01" && request_range[:to] == "2022-11-30"
      return true if payment['amount'].to_i == 324
    end
    false
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
    return true if tax_hash['totalEntitlement'].to_f <= 0 || tax_hash['childTaxCredit']['childCareAmount'].to_f <= 0
  end
end
