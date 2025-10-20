module Evidence
  class HmrcController < ApplicationController
    before_action :load_hmrc_check, only: [:show, :update]
    before_action :redirect_admin_to_show, only: [:new, :show]
    before_action :load_form, except: :update

    def show
      authorize evidence
      check_hmrc_data
      prepulated_additional_income
      add_missing_partner_data_message if hmrc_service.display_partner_data_missing_for_check?
      render :show
    end

    def new
      authorize evidence
      load_default_date_range
    end

    def create
      authorize evidence
      @form.update(hmrc_params.merge(additional_income: nil))

      if @form.valid? && hmrc_service_call
        redirect_to evidence_check_hmrc_path(evidence, @hmrc_check)
      else
        render :new
      end
    end

    def update
      @form = Forms::Evidence::HmrcCheck.new(@hmrc_check)
      authorize evidence
      if additional_income_updated?
        @evidence.calculate_evidence_income!
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
      if hmrc_service.call
        @form = hmrc_service.form
        @hmrc_check = hmrc_service.hmrc_check
        return true if @hmrc_check.valid?
      else
        @hmrc_check = hmrc_service.hmrc_check
        add_hmrc_check_error_message
      end

      false
    end

    def entitlement_check
      @entitlement_check = @hmrc_check.tax_credit_entitlement_check
    end

    def add_hmrc_check_error_message
      message = @hmrc_check.errors.full_messages.join(', ')
      @form.errors.add(:hmrc_check, message.to_s)
    end

    def hmrc_service
      @hmrc_service ||= HmrcService.new(evidence.application, @form)
    end

    def load_form
      check = load_hmrc_check || HmrcCheck.new(evidence_check: evidence)
      @form = Forms::Evidence::HmrcCheck.new(check)
      @form.user_id = current_user.id
      @form.additional_income = check.additional_income.positive?
      @form.additional_income_amount = check.additional_income
      @application_view = Views::Overview::Application.new(evidence.application)
    end

    def check_hmrc_data
      @hmrc_check.errors.add(:hmrc, @hmrc_check.error_response) unless entitlement_check

      applicant_data_check
      partner_data_check
    end

    def applicant_data_check
      applicant_check = @evidence.applicant_hmrc_check

      return if applicant_check.hmrc_income != 0
      message = I18n.t('hmrc_summary.no_income_applicant')
      @hmrc_check.errors.add(:income_calculation, message)
    end

    def partner_data_check
      partner_check = @evidence.partner_hmrc_check
      return if partner_check.blank? || partner_check.hmrc_income != 0

      message = I18n.t('hmrc_summary.no_income_partner')
      @hmrc_check.errors.add(:income_calculation, message)
    end

    def add_missing_partner_data_message
      message = I18n.t('hmrc_summary.no_income_partner')
      @hmrc_check.errors.add(:income_calculation, message)
    end

    def load_default_date_range
      @form = hmrc_service.load_form_default_data_range
    end

    def additional_income_updated?
      hmrc_service.update_additional_income(hmrc_params)
    end

    def prepulated_additional_income
      @form.load_additional_income_from_benefits
    end

    def redirect_admin_to_show
      return unless current_user.admin?
      redirect_to evidence_path(evidence)
    end
  end
end
