module Forms
  class FinanceReport
    include ActiveModel::Model

    attr_accessor :date_from
    attr_accessor :date_to
    attr_accessor :office
    attr_accessor :jurisdiction

    validates :date_to, :date_from, :office, :jurisdiction, presence: true

    validates :date_from, date: {
      before: :date_to
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
