module Evidence
  class AccuracyFailedReasonController < EvidenceController

    def show
      authorize evidence
      @form = Forms::Evidence::Accuracy.new(evidence)
    end

    def update
      @form = Forms::Evidence::Accuracy.new(evidence)
      if accuracy_reasons_check && save_accuracy_reasons
        redirect_to return_letter_evidence_path(evidence)
      else
        render :show
      end
    end

    private

    def accuracy_reasons_check
      return true if params.key?(:evidence)
      @form.errors.add(:incorrect_reason, 'Select from one of the options')
      false
    end

    def save_accuracy_reasons
      reasons = params.require(:evidence).permit(:incorrect_reason).to_h
      reasons.merge!(correct: false)
      @form.update_attributes(reasons)
      @form.save
    end

  end
end
