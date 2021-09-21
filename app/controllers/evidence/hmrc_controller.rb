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
      check_hmrc_data
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
      false
    rescue Net::ReadTimeout
      message = "HMRC income checking failed. Submit this form for HMRC income checking"
      @form.errors.add(:timout, message)
      false
    end

    def load_hmrc_check
      @hmrc_check = HmrcCheck.find(params[:id])
    end

    def check_hmrc_data
      return if @hmrc_check.total_income != 0
      message = "There might be an issue with HMRC data. Please contact technical support."
      @hmrc_check.errors.add(:income_calculation, message)
    end

  end
end
