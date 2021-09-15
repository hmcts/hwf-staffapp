module Evidence
  class HmrcController < ApplicationController

    def new
      authorize evidence
      @form = Forms::Evidence::HmrcCheck.new(evidence)
    end

    def create
      authorize evidence
      @form = Forms::Evidence::HmrcCheck.new(evidence)
      @form.update_attributes(hmrc_params)

      if @form.valid?
        hmrc_service_call
      else
        render :new
      end
    end

    private

    def evidence
      @evidence ||= EvidenceCheck.find(params[:evidence_check_id])
    end

    def hmrc_params
      params.require(:hmrc_check).permit(*Forms::Evidence::HmrcCheck.permitted_attributes).to_h
    end

    def hmrc_service_call
      hmrc_service = HmrcApiService.new(evidence.application)
      hmrc_service.income
      @hmrc_service = hmrc_service.hmrc_check
    end

  end

end