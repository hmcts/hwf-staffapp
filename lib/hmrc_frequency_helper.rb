module HmrcFrequencyHelper

  def multiplier_per_frequency(payment, request_range)
    @from = Date.parse(request_range[:from])
    @to = Date.parse(request_range[:to])

    return frequency(payment) if payment['frequency'] == 1

    end_date = Date.parse(payment['endDate'])
    start_date = Date.parse(payment['startDate'])

    list = frequency_days(start_date, end_date, payment)
    list.count do |day_iteration|
      next if @last_payment && (@last_payment < day_iteration)
      day_iteration.between?(@from, @to)
    end
  end

  def frequency(payment)
    return payment['frequency'] if @last_payment.blank?
    @last_payment < @to ? 0 : payment['frequency']
  end

  def frequency_days(day, end_date, payment)
    frequency = payment['frequency']

    return if frequency.zero?
    list = []
    while day < end_date
      day += frequency
      list << day if day <= end_date
    end

    list_parsed_by_may_cost_of_living(list, payment)
  end

end
