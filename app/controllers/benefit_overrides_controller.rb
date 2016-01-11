class BenefitOverridesController < ApplicationController
  before_action :authorise_benefit_override_create

  def paper_evidence
    @form = Forms::BenefitsEvidence.new(benefit_override)
  end

  def paper_evidence_save
    @form = Forms::BenefitsEvidence.new(benefit_override)
    @form.update_attributes(allowed_params)

    if @form.save
      redirect_to application_summary_path(application)
    else
      redirect_to application_benefit_override_paper_evidence_path(application)
    end
  end

  private

  def authorise_benefit_override_create
    authorize benefit_override, :create?
  end

  private

  def application
    @application ||= Application.find(params[:application_id])
  end

  def benefit_override
    @benefit_override ||= BenefitOverride.find_or_create_by(application_id: application.id)
  end

  def allowed_params
    params.require(:benefit_override).permit(*Forms::BenefitsEvidence.permitted_attributes)
  end
end
