class BenefitOverridesController < ApplicationController
  before_action :authorize_benefit_override_create

  def paper_evidence
    @form = Forms::BenefitsEvidence.new(benefit_override)
  end

  def paper_evidence_save
    @form = Forms::BenefitsEvidence.new(benefit_override)
    if allow_benefit_override? && no_paper_evidence?
      take_user_home
    else
      process_benefit_evidence
    end
  end

  private

  def authorize_benefit_override_create
    authorize benefit_override, :create?
  end

  def application
    @application ||= Application.find(params[:application_id])
  end

  def benefit_override
    @benefit_override ||= BenefitOverride.find_or_initialize_by(application: application)
  end

  def allowed_params
    return {} if params[:benefit_override].blank?
    params.require(:benefit_override).
      permit(*Forms::BenefitsEvidence.permitted_attributes.keys).to_h
  end

  def process_benefit_evidence
    @form.update(allowed_params)

    if @form.save
      redirect_to next_page_to_go
    else
      render :paper_evidence
    end
  end

  def allow_benefit_override?
    application.benefit_check_with_error_message? || DwpWarning.last&.check_state == DwpWarning::STATES[:offline]
  end

  def no_paper_evidence?
    allowed_params[:evidence] == 'false'
  end

  def take_user_home
    flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
    redirect_to root_url
  end

  def next_page_to_go
    if ucd_changes_apply?(application)
      application_declaration_path(application)
    else
      application_summary_path(application)
    end
  end

end
