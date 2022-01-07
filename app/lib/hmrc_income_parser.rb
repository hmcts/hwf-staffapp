module HmrcIncomeParser

  def self.paye(paye_hash)
    sum = paye_hash.sum do |i|
      i['grossEarningsForNics'].values.sum
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end

  def self.tax_credit(tax_credit_hash)
    sum = tax_credit_hash.sum do |i|
      i['payments'].sum do |payment|
        BigDecimal(payment['amount'].to_s)
      end
    end
    sum.is_a?(Numeric) ? sum : 0
  rescue NoMethodError, TypeError
    0
  end
end
