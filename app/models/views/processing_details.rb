module Views
  class ProcessingDetails
    attr_reader :application, :evidence_or_payment

    delegate :reference, to: :application

    def initialize(evidence_or_payment)
      @evidence_or_payment = evidence_or_payment
      @application = evidence_or_payment.application
    end

    def expires
      @evidence_or_payment.expires_at.to_date
    end

    def processed_by
      @application.user.name
    end

    def applicant
      @application.full_name
    end
  end
end
