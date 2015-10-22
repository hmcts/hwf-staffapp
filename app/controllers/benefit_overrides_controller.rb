class BenefitOverridesController < ApplicationController
  before_action :setup_application

  def paper_evidence
    @form = BenefitOverride.new(application_id: @application.id)
  end

  def paper_evidence_save
    evidence = allowed_params['correct']
    @form = BenefitOverride.find_or_create_by(application_id: @application.id)
    @form.correct = evidence

    if @form.save
      redirect_to application_build_path(application_id: @application.id, id: :summary)
    else
      redirect_to paper_evidence_path(@application)
    end
  end

  private

  def setup_application
    @application = Application.find(params[:application_id])
  end

  def allowed_params
    params.require(:benefit_override).permit(*Forms::BenefitsEvidence.permitted_attributes)
  end
end
