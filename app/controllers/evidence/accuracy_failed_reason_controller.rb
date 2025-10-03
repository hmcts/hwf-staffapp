module Evidence
  class AccuracyFailedReasonController < EvidenceController
    before_action :clear_reason_category, only: [:update]

    def show
      authorize evidence
      @form = Forms::Evidence::Accuracy.new(evidence)
    end

    def update
      @form = Forms::Evidence::Accuracy.new(evidence)
      if save_accuracy_reasons && accuracy_reasons_check
        return_application
        redirect_to return_letter_evidence_path(evidence)
      else
        render :show
      end
    end

    private

    def accuracy_reasons_check
      return true if valid_params?
      false
    end

    def save_accuracy_reasons
      reasons = params.require(:evidence).permit(:incorrect_reason, :staff_error_details).to_h
      reasons[:correct] = false
      @form.update(reasons)
      @form.save
    end

    def valid_params?
      return true unless params.key?(:evidence)
      return false if blank_reasons?
      return false if blank_error_details?
      true
    end

    def blank_reasons?
      return false if params[:evidence][:incorrect_reason].present?
      @form.errors.add(:incorrect_reason, 'Select from one of the options')
      true
    end

    def blank_error_details?
      if params[:evidence][:incorrect_reason] == 'staff_error' &&
         params[:evidence][:staff_error_details].blank?
        @form.errors.add(:staff_error_details, 'Please enter details of staff error')
        return true
      end
      false
    end

    def clear_reason_category
      evidence.clear_incorrect_reason_category!
    end

    def return_application
      ResolverService.new(evidence, current_user).return
    end
  end
end
