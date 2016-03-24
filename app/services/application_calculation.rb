class ApplicationCalculation
  def initialize(application)
    @application = application
  end

  def run
    unless @application.outcome == 'none'
      if @application.benefits
        BenefitCheckRunner.new(@application).run
      else
        IncomeCalculationRunner.new(@application).run
      end
    end
  end
end
