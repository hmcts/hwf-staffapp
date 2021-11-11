module Evidence
  class HmrcController < ApplicationController
    before_action :load_hmrc_check, only: [:show, :update]
    before_action :load_form, only: [:new, :create]

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
      load_form
      authorize evidence
      check_hmrc_data
      render :show
    end

    def update
      @form = Forms::Evidence::HmrcCheck.new(@hmrc_check)
      authorize evidence
      if redirect_to_summary?
        redirect_to evidence_check_hmrc_summary_path(@evidence, @hmrc_check)
      else
        render :show
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

    def load_form
      check = HmrcCheck.new(evidence_check: evidence)
      @form = Forms::Evidence::HmrcCheck.new(check)
    end

    def check_hmrc_data
      return if @hmrc_check.total_income != 0
      message = "There might be an issue with HMRC data. Please contact technical support."
      @hmrc_check.errors.add(:income_calculation, message)
    end

    # rubocop:disable Metrics/AbcSize
    def load_default_date_range
      received = @evidence.application.detail.date_received.to_date
      last_month = received - 1.month
      @form.from_date_day = last_month.beginning_of_month.day
      @form.from_date_month = last_month.month
      @form.from_date_year = last_month.year
      @form.to_date_day = last_month.end_of_month.day
      @form.to_date_month = last_month.month
      @form.to_date_year = last_month.year
    end
    # rubocop:enable Metrics/AbcSize

    def redirect_to_summary?
      return true if hmrc_params['additional_income'] == 'false'
      @form.additional_income = hmrc_params['additional_income']
      @form.additional_income_amount = hmrc_params['additional_income_amount']
      @form.save
    end
  end
end
