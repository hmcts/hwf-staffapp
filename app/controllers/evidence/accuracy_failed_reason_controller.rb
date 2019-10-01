module Evidence
  class AccuracyFailedReasonController < EvidenceController

    def show
      authorize evidence
      @form = Forms::Evidence::Accuracy.new(evidence)
    end

    def update
      @form = Forms::Evidence::Accuracy.new(evidence)

      if accuracy_reasons_check
        reasons = params.require(:evidence).permit(:incorrect_reason)
        @form.update_attributes(reasons)

        if @form.save
          redirect_to evidence_accuracy_incorrect_reason_path(evidence)
        else
          render :show
        end
      else
        render :show
      end
    end

    private

    def accuracy_reasons_check
      return true if params.has_key?(:evidence)
      @form.errors.add(:incorrect_reason, 'Please select from one of the options')
      false
    end

  end
end
