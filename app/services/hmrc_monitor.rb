# Mirrors DwpMonitor for the HMRC income check. Drives the HMRC banner only;
# it never blocks any functionality - see CHANGELOG.md.
class HmrcMonitor
  def initialize
    hmrc_results
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

  def hmrc_results
    @checks = HmrcCheck.order('id desc').limit(10).pluck(:error_response)
  end

  def percent
    return 0 unless @checks.any?
    total = @checks.count.to_f
    (error_count / total) * 100.0
  end

  def error_count
    @checks.count { |error_response| HmrcCheck.service_failure?(error_response) }.to_f
  end
end
