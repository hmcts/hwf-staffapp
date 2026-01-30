module Forms
  module Report
    class FinanceTransactionalReport
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations::Callbacks
      include FinanceReportHelper

      attribute :date_from, :date
      attribute :day_date_from, :integer
      attribute :month_date_from, :integer
      attribute :year_date_from, :integer
      attribute :date_to, :date
      attribute :day_date_to, :integer
      attribute :month_date_to, :integer
      attribute :year_date_to, :integer
      attribute :sop_code, :string
      attribute :refund, :boolean
      attribute :application_type, :string
      attribute :jurisdiction_id, :integer

      def initialize(attrs = {})
        super
        nullify_blanks
      end

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

      private

      def nullify_blanks
        [:sop_code, :application_type].each do |attr|
          value = send(attr)
          send(:"#{attr}=", nil) if value.is_a?(String) && value.blank?
        end
      end
    end
  end
end
