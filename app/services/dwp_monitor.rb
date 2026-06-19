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

  def dwp_results
    @checks = BenefitCheck.order('id desc').limit(10).pluck(:dwp_result, :error_message)
  end

  def percent
    return 0 unless @checks.any?
    total = @checks.count.to_f
    (error_count / total) * 100.0
  end

  def error_count
    @checks.count { |check| error?(check) }.to_f
  end

  # Shares its definition of a failure with the rerun job via BenefitCheck, so
  # what the dashboard counts as 'offline' and what gets re-run stay in step.
  def error?(check)
    BenefitCheck.dwp_outage_failure?(check[0], check[1])
  end
end
