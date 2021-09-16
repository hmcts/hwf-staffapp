module Evidence
  class HmrcController < ApplicationController

    def new
      authorize evidence
      @form = Forms::Evidence::HmrcCheck.new(HmrcCheck.new)
    end

    def create
      authorize evidence
      @form = Forms::Evidence::HmrcCheck.new(HmrcCheck.new)
      @form.update_attributes(hmrc_params)

      if @form.valid?
        hmrc_service_call
        render html: 'good'
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
      hmrc_service.income(@form.from_date, @form.to_date)
      @hmrc_service = hmrc_service.hmrc_check
    end
  end

end