module HmrcCostOfLiving

  # RST-4697 for more info
  def cost_of_living_credit(payment, request_range)
    return true if september_match?(request_range, payment)
    return true if november_match?(request_range, payment)
    return true if may_match?(request_range, payment)
    return true if november_23_match?(request_range, payment)
    false
  end

  # RST-5346 for more info
  def included_in_may_date_range?(payment)
    list = [Date.parse(payment['startDate']), Date.parse(payment['endDate'])]
    parsed_list = list_parsed_by_may_cost_of_living(list, payment)

    parsed_list.size != 2
  end

  # RST-6056 for more info
  def included_in_november_23_date_range?(payment)
    list = [Date.parse(payment['startDate']), Date.parse(payment['endDate'])]
    parsed_list = list_parsed_by_november_23_cost_of_living(list, payment)

    parsed_list.size != 2
  end

  def list_parsed_by_may_cost_of_living(list, payment)
    parsed_list = []

    list.each do |date|
      case date
      when Date.parse('2 May 2023')..Date.parse('9 May 2023')
        next if payment['amount'].to_i == 301
      else
        parsed_list << date
      end
    end

    parsed_list
  end

  def list_parsed_by_november_23_cost_of_living(list, payment)
    parsed_list = []

    list.each do |date|
      case date
      when Date.parse('10 November 2023')..Date.parse('19 November 2023')
        next if payment['amount'].to_i == 300
      else
        parsed_list << date
      end
    end
    parsed_list
  end

  private

  def september_match?(request_range, payment)
    request_range[:from] == "2022-09-01" &&
      request_range[:to] == "2022-09-30" &&
      payment['amount'].to_i == 326
  end

  def november_match?(request_range, payment)
    request_range[:from] == "2022-11-01" &&
      request_range[:to] == "2022-11-30" &&
      payment['amount'].to_i == 324
  end

  def may_match?(request_range, payment)
    request_range[:from] == "2023-05-01" &&
      request_range[:to] == "2023-05-31" &&
      payment['frequency'] == 1 &&
      payment['amount'].to_i == 301 && included_in_may_date_range?(payment)
  end

  def november_23_match?(request_range, payment)
    request_range[:from] == "2023-11-01" &&
      request_range[:to] == "2023-11-30" &&
      payment['frequency'] == 1 &&
      payment['amount'].to_i == 300 && included_in_november_23_date_range?(payment)
  end

end
