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
    @deleted_reasons = delete_reasons
    @form = Forms::Application::Delete.new(application)
    assign_views

    track_application(application)
  end

  def flow
    authorize application
    @events_by_page = Ahoy::Event.
                      where(application_id: application.id).
                      order(:time).
                      group_by { |event| event.properties&.dig('page') || 'Unknown Page' }
  end

  def update
    @deleted_reasons = delete_reasons
    @form = Forms::Application::Delete.new(application)
    @form.update(delete_params)
    authorize application
    save_and_respond_on_update
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

  def delete_reasons
    ['Incorrect application fee entered', 'Typo/spelling error',
     'Duplicate application - should not have been processed', 'Evidence out of time and processed in error',
     'Out of jurisdiction claim/wrong court', 'Other error made by office processing application',
     'Multiple applicants for one court application', 'Unable to proceed with main court application',
     'Issued in error - application should be for a refund', 'Customer error on completion of application']
  end

  def save_and_respond_on_update
    if @form.save
      ResolverService.new(application, current_user).delete
      flash[:notice] = I18n.t('processed_applications.notice.deleted')
      redirect_to(action: :index)
    else
      assign_views
      render :show
    end
  end

  def query_object
    Query::ProcessedApplications.new(current_user).find(filter)
  end

end
