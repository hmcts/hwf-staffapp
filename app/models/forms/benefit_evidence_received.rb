module Forms
  # Asked on the processed application page for a failed benefit application.
  # Answering yes reprocesses the application as a full remission
  # (see ReprocessBenefitApplication and CHANGELOG.md).
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
