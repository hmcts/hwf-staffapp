module Forms
  class FinanceReport
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
    attribute :be_code, String
    attribute :refund, Boolean
    attribute :application_type, String
    attribute :jurisdiction_id, Integer
    attribute :entity_code, String

    validates :date_to, :date_from, presence: true

    validates :date_to, date: {
      after: :date_from, allow_blank: true
    }

    validates :entity_code, presence: true, unless: proc { |form| form.entity_code.nil? }

    before_validation :format_dates

    def i18n_scope
      "activemodel.attributes.forms/finance_report".to_sym
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
