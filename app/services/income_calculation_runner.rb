class IncomeCalculationRunner
  def initialize(application)
    @application = application
  end

  def run
    income_calculation_result = IncomeCalculation.new(@application).calculate
    if income_calculation_result
      @application.update({ application_type: 'income' }.merge(income_calculation_result))
    end
  end
end
