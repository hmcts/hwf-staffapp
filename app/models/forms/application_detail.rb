module Forms
  class ApplicationDetail < Base

    TIME_LIMIT_FOR_PROBATE = 20

    def self.permitted_attributes
      { fee: Integer,
        jurisdiction_id: Integer,
        date_received: Date,
        probate: Boolean,
        date_of_death: Date,
        deceased_name: String,
        refund: Boolean,
        date_fee_paid: Date,
        form_name: String,
        case_number: String }
    end

    define_attributes

    validates :fee, numericality: { allow_blank: true }
    validates :fee, presence: true
    validates :jurisdiction_id, presence: true

    validates :date_received, date: {
      after: proc { Time.zone.today - 3.months },
      before: proc { Time.zone.today + 1.day }
    }

    with_options if: :probate? do
      validates :deceased_name, presence: true
      validates :date_of_death, date: {
        after: proc { Time.zone.today - TIME_LIMIT_FOR_PROBATE.years },
        before: proc { Time.zone.today + 1.day }
      }
    end

    with_options if: :refund? do
      validates :date_fee_paid, date: {
        after: proc { Time.zone.today - 3.months },
        before: proc { Time.zone.today + 1.day }
      }
    end
  end
end
