class BenefitOverridesController < ApplicationController
  before_action :setup_application, :form_object

  def paper_evidence
  end

  def paper_evidence_save
    @form.update_attributes(allowed_params)

    if @form.save
      redirect_to application_summary_path(@application)
    else
      redirect_to application_benefit_override_paper_evidence_path(@application)
    end
  end

  private

  def setup_application
    @application = Application.find(params[:application_id])
  end

  def benefit_override
    BenefitOverride.find_or_create_by(application_id: @application.id)
  end

  def form_object
    @form = Forms::BenefitsEvidence.new(benefit_override)
  end

  def allowed_params
    params.require(:benefit_override).permit(*Forms::BenefitsEvidence.permitted_attributes)
  end
end
