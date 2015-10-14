module Views
  class ApplicationResult

    def initialize(evidence)
      @evidence = evidence
    end

    def result
      %w[full part none].include?(@evidence.outcome) ? @evidence.outcome : 'error'
    end

    def amount_to_pay
      "£#{@evidence.amount_to_pay.round}" if @evidence.amount_to_pay.present?
    end

    def savings
      result_translations[@evidence.application.savings_investment_valid?.to_s]
    end

    def income
      result_translations[%w[full part].include?(result).to_s]
    end

    private

    def result_translations
      {
        'true' => I18n.t('activerecord.attributes.application.summary.passed'),
        'false' => I18n.t('activerecord.attributes.application.summary.failed')
      }
    end
  end
end
