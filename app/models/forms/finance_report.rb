module Forms
  class FinanceReport
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
    attribute :entity_code, String
    attribute :all_offices, Boolean

    validates :date_to, :date_from, presence: true

    validates :date_to, comparison: { greater_than: :date_from }, allow_blank: true

    validates :entity_code, presence: true, unless: proc { |form|
      form.all_offices || form.entity_code.nil?
    }

    before_validation :format_dates

    def i18n_scope
      :'activemodel.attributes.forms/finance_report'
    end

  end
end
