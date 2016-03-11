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

    validates :fee, numericality: { allow_blank: false }
    validates :jurisdiction_id, presence: true
    validates :emergency_reason, presence: true, if: :emergency?
  end
end
