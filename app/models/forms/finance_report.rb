module Forms
  class FinanceReport
    include Virtus.model(nullify_blank: true)
    include ActiveModel::Model

    attribute :date_from, Date
    attribute :date_to, Date

    validates :date_to, :date_from, presence: true

    validates :date_to, date: {
      after: :date_from, allow_blank: true
    }

    def i18n_scope
      "activemodel.attributes.forms/finance_report".to_sym
    end

    def start_date
      date_from.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
    end

    def end_date
      date_to.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
    end
  end
end
