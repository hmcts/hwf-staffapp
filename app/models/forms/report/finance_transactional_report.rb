module Forms
  module Report
    class FinanceTransactionalReport
      include Virtus.model(nullify_blank: true)
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

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

      validates :date_to, date: {
        after: :date_from, allow_blank: true,
        before: proc { |obj| obj.date_from + 2.years },
        message: "The date range can't be longer than 2 years"
      }, if: :date_from

      before_validation :format_dates

      def i18n_scope
        :"activemodel.attributes.forms/report/finance_transactional_report"
      end

      def start_date
        date_from.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
      end

      def end_date
        date_to.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
      end

      private

      def format_dates
        [:date_from, :date_to].each do |date_attr_name|
          instance_variable_set("@#{date_attr_name}", concat_dates(date_attr_name).to_date)
        rescue StandardError
          instance_variable_set("@#{date_attr_name}", concat_dates(date_attr_name))
        end
      end

      def concat_dates(date_attr_name)
        day = send("day_#{date_attr_name}")
        month = send("month_#{date_attr_name}")
        year = send("year_#{date_attr_name}")
        return '' if day.blank? || month.blank? || year.blank?

        "#{day}/#{month}/#{year}"
      end

    end
  end
end
