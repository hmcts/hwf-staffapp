module Forms
  class ApplicationDetails
    include ActiveModel::Model
    PERMITTED_ATTRIBUTES = %i[fee jurisdiction_id date_received]

    attr_accessor *PERMITTED_ATTRIBUTES

    validates :fee, numericality: { allow_blank: true }
    validates :fee, presence: true
    validates :jurisdiction_id, presence: true

    validates :date_received, date: {
      after: proc { Time.zone.today - 3.months },
      before: proc { Time.zone.today + 1.day }
    }
  end
end
