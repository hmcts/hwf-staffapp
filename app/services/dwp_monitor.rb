class DwpMonitor

  def initialize
    dwp_results
  end

  def state
    if percent >= 50.0
      'offline'
    elsif percent >= 25.0
      'warning'
    else
      'online'
    end
  end

  private

  def dwp_results
    @checks = BenefitCheck.pluck(:dwp_result, :error_message).last(20)
  end

  def percent
    return 0 unless @checks.any?
    # When DWP is offline it returns 400 Bad Request
    # maybe extend to search for x00 as first 3 chars to check for 500 errors too
    total = @checks.count.to_f
    bad = @checks.flatten.count('400 Bad Request').to_f
    bad / total * 100.0
  end
end
