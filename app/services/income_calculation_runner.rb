class IncomeCalculationRunner
  def initialize(application)
    @application = application
  end

  def run
    income_calculation_result = IncomeCalculation.new(@application).calculate
    if income_calculation_result
      @application.update(
        application_type: 'income',
        outcome: income_calculation_result[:outcome],
        amount_to_pay: income_calculation_result[:amount_to_pay],
        income_min_threshold: income_calculation_result[:min_threshold],
        income_max_threshold: income_calculation_result[:max_threshold]
      )
    end
  end
end
