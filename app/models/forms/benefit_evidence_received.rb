module Forms
  # Asked on the processed application page for a failed benefit application.
  # Both answers are recorded as an Appeal and set the decision
  # (see RecordAppeal and CHANGELOG.md).
  class BenefitEvidenceReceived < ::FormObject
    def self.permitted_attributes
      {
        evidence: :boolean
      }
    end

    define_attributes

    validates :evidence, inclusion: { in: [true, false] }
  end
end
