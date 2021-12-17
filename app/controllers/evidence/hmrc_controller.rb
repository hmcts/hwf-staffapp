module Evidence
  class HmrcController < ApplicationController
    before_action :load_hmrc_check, only: [:show, :update]
    before_action :load_form, except: :update

    def new
      authorize evidence
      load_default_date_range
    end

    def create
      authorize evidence
      @form.update_attributes(hmrc_params.merge(additional_income: nil))

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

    def update
      @form = Forms::Evidence::HmrcCheck.new(@hmrc_check)
      authorize evidence
      if additional_income_updated?
        @hmrc_check.calculate_evidence_income!
        redirect_to evidence_check_hmrc_summary_path(@evidence, @hmrc_check)
      else
        render :show
      end
    end

    private

    def evidence
      @evidence ||= EvidenceCheck.find(params[:evidence_check_id])
    end

    def load_hmrc_check
      return if params[:id].blank?
      @hmrc_check ||= HmrcCheck.find(params[:id])
    end

    def hmrc_params
      params.require(:hmrc_check).permit(*Forms::Evidence::HmrcCheck.permitted_attributes).to_h
    end

    def hmrc_service_call
      hmrc_service.call
      @form = hmrc_service.form
      @hmrc_check = hmrc_service.hmrc_check
    end

    def hmrc_service
      @hmrc_service ||= HmrcService.new(evidence.application, @form)
    end

    def load_form
      check = load_hmrc_check || HmrcCheck.new(evidence_check: evidence)
      @form = Forms::Evidence::HmrcCheck.new(check)
      @form.additional_income = check.additional_income.positive?
      @form.additional_income_amount = check.additional_income
      @application_view = Views::Overview::Application.new(evidence.application)
    end

    def check_hmrc_data
      return if @hmrc_check.total_income != 0
      message = "There might be an issue with HMRC data. Please contact technical support."
      @hmrc_check.errors.add(:income_calculation, message)
    end

    def load_default_date_range
      @form = hmrc_service.load_form_default_data_range
    end

    def additional_income_updated?
      hmrc_service.update_additional_income(hmrc_params)
    end
  end
end
