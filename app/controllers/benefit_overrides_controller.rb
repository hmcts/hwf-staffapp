class BenefitOverridesController < ApplicationController
  before_action :authorize_benefit_override_create

  def paper_evidence
    @form = Forms::BenefitsEvidence.new(benefit_override)
  end

  def paper_evidence_save
    @form = Forms::BenefitsEvidence.new(benefit_override)
    @form.update_attributes(allowed_params)

    if @form.save
      redirect_to application_summary_path(application)
    else
      render :paper_evidence
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
    params.require(:benefit_override).permit(*Forms::BenefitsEvidence.permitted_attributes.keys)
  end
end
