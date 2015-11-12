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
        amount_to_pay: income_calculation_result[:amount]
      )
    end
  end
end
