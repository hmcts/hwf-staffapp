module Forms
  class ApplicationDetails
    include ActiveModel::Model
    PERMITTED_ATTRIBUTES = %i[fee jurisdiction_id date_received probate date_of_death deceased_name refund date_fee_paid]

    # rubocop:disable AmbiguousOperator
    attr_accessor *PERMITTED_ATTRIBUTES

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

    [:probate, :refund].each { |attr| define_method("#{attr}?") { send("#{attr}") } }

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
