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
    @checks = BenefitCheck.order(:id).pluck(:dwp_result, :error_message).last(20)
  end

  def percent
    return 0 unless @checks.any?
    # When DWP is offline it returns 400 Bad Request
    # maybe extend to search for x00 as first 3 chars to check for 500 errors too
    total = @checks.count.to_f
    (error_total / total) * 100.0
  end

  def error_total
    internal_server_error = @checks.flatten.count('500 Internal Server Error').to_f
    bad_request = @checks.flatten.count('BadRequest').to_f
    server_broke = @checks.flatten.count('Server broke connection').to_f
    bad_request + server_broke + internal_server_error
  end
end
