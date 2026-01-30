module Forms
  module FinanceReportHelper
    def start_date
      date_from.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
    end

    def end_date
      date_to.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
    end

    private

    def format_dates
      [:date_from, :date_to].each do |date_attr_name|
        send(:"#{date_attr_name}=", concat_dates(date_attr_name).to_date)
      rescue StandardError
        send(:"#{date_attr_name}=", concat_dates(date_attr_name))
      end
    end

    def concat_dates(date_attr_name)
      day = send(:"day_#{date_attr_name}")
      month = send(:"month_#{date_attr_name}")
      year = send(:"year_#{date_attr_name}")
      return '' if day.blank? || month.blank? || year.blank?

      "#{day}/#{month}/#{year}"
    end

  end
end
