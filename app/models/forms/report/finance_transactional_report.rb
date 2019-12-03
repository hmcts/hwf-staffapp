module Forms
  module Report
    class FinanceTransactionalReport
      include Virtus.model(nullify_blank: true)
      include ActiveModel::Model

      attribute :date_from, Date
      attribute :date_to, Date

      validates :date_to, :date_from, presence: true

      validates :date_to, date: {
        after: :date_from, allow_blank: true,
        before: proc { |obj| obj.date_from + 2.years },
        message: "The date range can't be longer than 2 years"
      }, if: :date_from

      def i18n_scope
        "activemodel.attributes.forms/report/finance_transactional_report".to_sym
      end

      def start_date
        date_from.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
      end

      def end_date
        date_to.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
      end
    end
  end
end
