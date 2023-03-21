# frozen_string_literal: true

class BandBaseCalculation
  attr_reader :income, :fee, :saving_amount
  def initialize(application)
    @income = application.income
    @fee = application.detail.fee
    @saving_amount = application.saving.amount
    # @children = application.children
    # @married = application.applicant.married
    # @dob = application.applicant.dob
  end

  # -	Value of fee up to £1420: capital threshold = £4250,
  # -	Value of fee £1421 to £5000: capital threshold= 3x fee charged,
  # -	Value of fee £5001 or over: capital threshold= £16000.

  # Capital threshold
  # •	Minimum threshold = Band 1 (£4,250)
  # •	Maximum threshold = Band 3 (£16,00)
  # •	Where Savings & Investments Equal to or Less than Minimum threshold THEN banding applies - see below
  # •	Where Savings & Investments Greater than Minimum threshold but Less than Maximum threshold THEN banding applies - see below
  # •	Where Savings & Investments Greater than Maximum threshold THEN Not Eligible for help with fees



  # capital threshold calculation - savings
  # If fee is under 1420 then the capital threshold is 4250 aka 3*1420
  # If fee is between 1421 and 5000 then the capital threshold is  3*fee so max 15000
  # If fee is between more then 5001 then the capital threshold is 16000
  def saving_threshold_exceeded?
    case fee
    when 0..1420
      (saving_amount <= 4250) ? false : true
    when 1421..5000
      (saving_amount < (fee * 3)) ? false : true
    when 5001..Float::INFINITY
      (saving_amount <= 16000) ? false : true
    end
  end

  #
  # def band_calculation(band, income)
  #   case band
  #   when 1
  #     income * 0.5
  #   when 2
  #     inc = income - 1000
  #     calc = 500
  #     calc += inc * 0.7
  #     calc
  #   when 3
  #     inc = income - 2000
  #     calc = 500 + 700
  #     calc += inc * 0.9
  #     calc
  #   end
  # end
  #
  # # no premium
  # def income_calc(income, fee)
  #   min_threshold = 1420
  #
  #   case income
  #   when 0..1420
  #     return 0
  #   when 1421..2420
  #     sum = band_calculation(1,income - min_threshold)
  #     round_down_to_nearest_10(sum)
  #     sum
  #   when 2421..3420
  #     sum = band_calculation(2,income - min_threshold)
  #     round_down_to_nearest_10(sum)
  #   when 3421..4420
  #     sum = band_calculation(3,income - min_threshold)
  #     round_down_to_nearest_10(sum)
  #   when 4421..Float::INFINITY
  #     -1
  #   end
  # end
  #
  #
  #
  #
  # def premiums(married,kids)
  #   total = 0
  #   total += 710 if married
  #   total += kids.sum do |age|
  #     case age
  #     when 0..13
  #       425
  #     when 14..17
  #       710
  #     else
  #       0
  #     end
  #   end
  # end
  #
  #
  # min_threshold = 1420
  # max_threshold = 3000
  #
  # remissions(3200, 183, true, [10,15])
  # remissions(6560, 1350, true, [16,17])
  # remissions(5300, 1350, true, [10,13,15])
  #
  # remissions(1400, 232, true, [])
  # remissions(5500, 250, true, [])
  # remissions(4000, 2000, true, [])
  # remissions(2000, 600, true, [])
  #
  # def remissions(income, fee, married, kids)
  #   min_threshold = 1420
  #   if kids.blank?
  #     sum = income_calc(income, fee)
  #     if sum == 0
  #       puts "Eligible full fee"
  #     elsif sum.negative?
  #       puts "Not eligible"
  #     end
  #     sum
  #   else
  #     income_cap = min_threshold + premiums(married, kids)
  #     income_to_use = income - income_cap
  #     return "Eligible full fee" if income_to_use.negative?
  #
  #     case income_to_use
  #     when 0..1420
  #       sum = band_calculation(1,income_to_use)
  #     when 1421..2420
  #       sum = band_calculation(2,income_to_use)
  #     when 2421..3420
  #       sum = band_calculation(3,income_to_use)
  #     end
  #     sum = round_down_to_nearest_10(sum)
  #   end
  #   cost= fee - sum
  #   puts "Not eligible" if cost.negative?
  #   cost
  # end
end
