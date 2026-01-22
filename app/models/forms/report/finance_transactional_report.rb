module Forms
  module Report
    class FinanceTransactionalReport
      include Virtus.model(nullify_blank: true)
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks
      include FinanceReportHelper

      attribute :date_from, Date
      attribute :day_date_from, Integer
      attribute :month_date_from, Integer
      attribute :year_date_from, Integer
      attribute :date_to, Date
      attribute :day_date_to, Integer
      attribute :month_date_to, Integer
      attribute :year_date_to, Integer
      attribute :sop_code, String
      attribute :refund, Boolean
      attribute :application_type, String
      attribute :jurisdiction_id, Integer

      validates :date_to, :date_from, presence: true

      validates :date_to, comparison: { greater_than: :date_from }, allow_blank: true, if: :date_from
      validates :date_to, comparison: {
        less_than: ->(record) { record.date_from + 2.years },
        message: I18n.t("activemodel.errors.models.forms/report/finance_transactional_report.date_range_length")
      }, allow_blank: true, if: :date_from

      before_validation :format_dates

      def i18n_scope
        :'activemodel.attributes.forms/report/finance_transactional_report'
      end

    end
  end
end
