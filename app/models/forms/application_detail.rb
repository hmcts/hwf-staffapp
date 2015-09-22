module Forms
  class ApplicationDetail
    include Virtus.model(nullify_blank: true)

    include ActiveModel::Model

    PERMITTED_ATTRIBUTES = { fee: Integer,
                             jurisdiction_id: Integer,
                             date_received: Date,
                             probate: Boolean,
                             date_of_death: Date,
                             deceased_name: String,
                             refund: Boolean,
                             date_fee_paid: Date,
                             form_name: String,
                             case_number: String }

    PERMITTED_ATTRIBUTES.each { |attr, type| attribute attr, type }

    def initialize(object)
      attrs = extract_params(object)
      super(attrs)
    end

    validates :fee, numericality: { allow_blank: true }
    validates :fee, presence: true
    validates :jurisdiction_id, presence: true

    validates :date_received, date: {
      after: proc { Time.zone.today - 3.months },
      before: proc { Time.zone.today + 1.day }
    }

    with_options if: :probate? do
      validates :deceased_name, presence: true
      validates :date_of_death, date: { before: proc { Time.zone.today + 1.day } }
    end

    with_options if: :refund? do
      validates :date_fee_paid, date: {
        after: proc { Time.zone.today - 3.months },
        before: proc { Time.zone.today + 1.day }
      }
    end

    private

    def extract_params(object)
      get_attribs(object).select do |key, _|
        PERMITTED_ATTRIBUTES.include?(key.to_sym)
      end
    end

    def get_attribs(object)
      object.is_a?(Application) ? object.attributes : object
    end
  end
end
