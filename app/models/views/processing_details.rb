module Views
  class ProcessingDetails
    attr_reader :application, :evidence_or_payment

    delegate :reference, to: :application

    def initialize(evidence_or_payment)
      @evidence_or_payment = evidence_or_payment
      @application = evidence_or_payment.application
    end

    def expires
      return 'expired' if @evidence_or_payment.expires_at < Time.zone.now
      days = (((@evidence_or_payment.expires_at - Time.zone.now) / 86400).round)
      if days > 1
        "#{days} days"
      elsif days == 1
        "1 day"
      end
    end

    def processed_by
      @application.user.name
    end

    def applicant
      @application.full_name
    end
  end
end
