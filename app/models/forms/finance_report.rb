module Forms
  class FinanceReport
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
    attribute :entity_code, :string
    attribute :all_offices, :boolean

    def initialize(attrs = {})
      super(attrs)
      nullify_blanks
    end

    validates :date_to, :date_from, presence: true

    validates :date_to, comparison: { greater_than: :date_from }, allow_blank: true

    validates :entity_code, presence: true, unless: proc { |form|
      form.all_offices || form.entity_code.nil?
    }

    before_validation :format_dates

    def i18n_scope
      :'activemodel.attributes.forms/finance_report'
    end

    private

    def nullify_blanks
      [:sop_code, :application_type, :entity_code].each do |attr|
        value = send(attr)
        send(:"#{attr}=", nil) if value.is_a?(String) && value.blank?
      end
    end
  end
end
