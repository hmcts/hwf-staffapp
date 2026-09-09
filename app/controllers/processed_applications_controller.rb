class ProcessedApplicationsController < ApplicationController
  include ProcessedViewsHelper
  include FilterApplicationHelper

  def index
    authorize :application

    @applications = paginated_applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application
    prepare_show

    track_application(application)
  end

  def update
    @deleted_reasons = delete_reasons
    @form = Forms::Application::Delete.new(application)
    @form.update(delete_params)
    authorize application
    save_and_respond_on_update
  end

  def destroy
    authorize application
    application.really_destroy!
    flash[:notice] = I18n.t('processed_applications.notice.deleted')
    redirect_to root_path
  end

  def benefit_evidence
    authorize application
    @evidence_form = Forms::BenefitEvidenceReceived.new(benefit_evidence_params)

    if @evidence_form.valid?
      reprocess_when_evidence_received
      redirect_to processed_application_path(application)
    else
      prepare_show
      render :show
    end
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def paginated_applications
    @paginate ||= paginate(
      policy_scope(query_object)
    )
  end

  def delete_params
    params.require(:application).permit(*Forms::Application::Delete.permitted_attributes.keys).to_h
  end

  def benefit_evidence_params
    return {} if params[:benefit_evidence].blank?
    params.require(:benefit_evidence).permit(*Forms::BenefitEvidenceReceived.permitted_attributes.keys).to_h
  end

  def delete_reasons
    ['Incorrect application fee entered', 'Typo/spelling error',
     'Duplicate application - should not have been processed', 'Evidence out of time and processed in error',
     'Out of jurisdiction claim/wrong court', 'Other error made by office processing application',
     'Multiple applicants for one court application', 'Unable to proceed with main court application',
     'Issued in error - application should be for a refund', 'Customer error on completion of application']
  end

  def prepare_show
    @deleted_reasons = delete_reasons
    @form ||= Forms::Application::Delete.new(application)
    @evidence_form ||= Forms::BenefitEvidenceReceived.new({})
    assign_views
  end

  def reprocess_when_evidence_received
    return unless @evidence_form.evidence?

    ReprocessBenefitApplication.new(application, current_user).call
    flash[:notice] = I18n.t('processed_applications.notice.benefit_evidence_received')
  end

  def save_and_respond_on_update
    if @form.save
      ResolverService.new(application, current_user).delete
      flash[:notice] = I18n.t('processed_applications.notice.deleted')
      redirect_to(action: :index)
    else
      prepare_show
      render :show
    end
  end

  def query_object
    Query::ProcessedApplications.new(current_user).find(filter)
  end

end
