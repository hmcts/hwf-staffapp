class ProcessedApplicationsController < ApplicationController
  include ProcessedViewsHelper

  def index
    authorize :application

    @applications = paginated_applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    @form = Forms::Application::Delete.new(application)
    assign_views

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  def update
    @form = Forms::Application::Delete.new(application)
    @form.update_attributes(delete_params)
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
    params.require(:application).permit(*Forms::Application::Delete.permitted_attributes.keys)
  end

  def save_and_respond_on_update
    if @form.save
      ResolverService.new(application, current_user).delete
      flash[:notice] = 'The application has been deleted'
      redirect_to(action: :index)
    else
      assign_views
      render :show
    end
  end

  def query_object
    Query::ProcessedApplications.new(current_user).find
  end
end
