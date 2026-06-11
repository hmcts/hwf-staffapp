class DwpMonitor
  VALID_RESULTS = %w[Yes No].freeze

  VALIDATION_ERROR_PATTERNS = [
    'is invalid',
    'is not valid',
    'is missing'
  ].freeze

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

  def error?(check)
    dwp_result = check[0]
    error_message = check[1]

    return false if VALID_RESULTS.include?(dwp_result)
    return false if dwp_result == 'BadRequest' && validation_error?(error_message)

    true
  end

  def validation_error?(error_message)
    return true if error_message.blank?

    VALIDATION_ERROR_PATTERNS.any? { |pattern| error_message.include?(pattern) }
  end
end
