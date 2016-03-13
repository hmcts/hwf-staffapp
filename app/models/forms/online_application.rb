module Forms
  class OnlineApplication < FormObject
    def self.permitted_attributes
      { fee: Integer,
        jurisdiction_id: Integer,
        form_name: String,
        emergency: Boolean,
        emergency_reason: String }
    end

    define_attributes

    validates :fee, numericality: { allow_blank: true }, presence: true
    validates :jurisdiction_id, presence: true
    validates :emergency_reason, presence: true, if: :emergency?
    validates :emergency_reason, length: { maximum: 500 }

    def persist!
      @object.update(fields_to_update)
    end

    def fields_to_update
      { fee: fee, jurisdiction_id: jurisdiction_id, form_name: form_name }.tap do |fields|
        fields[:emergency_reason] = emergency_reason if emergency
      end
    end
  end
end
