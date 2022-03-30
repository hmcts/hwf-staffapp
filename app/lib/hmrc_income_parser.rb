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
      i['payments'].sum do |payment|
        tax_credit_amount(payment, request_range)
      end
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end

  def self.tax_credit_amount(payment, request_range)
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

    list.select { |day_iteration| day_iteration >= from && day_iteration <= to }.count
  end

  def self.frequency_days(day, end_date, frequency)
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
end
