module Evidence
  class AccuracyIncorrectReasonController < EvidenceController
    def show
      authorize evidence
      @form = Forms::Evidence::Accuracy.new(evidence)
    end

    def update
      @form = Forms::Evidence::Accuracy.new(evidence)

      if accuracy_reasons_check
        @form.update_attributes(incorrect_reason_category: category_params)

        if @form.save
          redirect_to summary_evidence_path
        else
          render :show
        end
      else
        render :show
      end
    end

    private

    def accuracy_reasons_check
      return true unless category_params.blank?
      @form.errors.add(:incorrect_reason_category, 'Please select from one of the options')
      false
    end

    def category_params
      return {} unless params.has_key?(:accuracy_incorrect_reason)
      params.require(:accuracy_incorrect_reason)
        .permit(incorrect_reason_category: [])[:incorrect_reason_category]
        .select { |value| value != '0' }

    end


  end
end
