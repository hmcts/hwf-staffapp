module Evidence
  class HmrcController < ApplicationController
    before_action :load_hmrc_check, only: :show

    def new
      authorize evidence
      @form = Forms::Evidence::HmrcCheck.new(HmrcCheck.new)
    end

    def create
      authorize evidence
      @form = Forms::Evidence::HmrcCheck.new(HmrcCheck.new)
      @form.update_attributes(hmrc_params)

      if @form.valid? && hmrc_service_call
        redirect_to evidence_check_hmrc_path(evidence, @hmrc_check)
      else
        render :new
      end
    end

    def show
      authorize evidence
      render :show
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
      @hmrc_check = hmrc_service.hmrc_check
    rescue HwfHmrcApiError => e
      @form.errors.add(:request, e.message)
      return false
    end

    def load_hmrc_check
      @hmrc_check = HmrcCheck.find(params[:id])
    end

  end
end
