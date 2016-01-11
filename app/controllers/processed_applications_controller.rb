class ProcessedApplicationsController < ApplicationController
  include ProcessedViewsHelper
  helper ReferenceHelper

  def index
    authorize :application

    @applications = applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    @form = Forms::Application::Delete.new(application)
    assign_views
  end

  def update
    # TODO: The authorisation should be done after the attributes have been updated
    authorize application

    @form = Forms::Application::Delete.new(application)
    @form.update_attributes(delete_params)
    save_and_respond_on_update
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def applications
    @applications ||= policy_scope(Query::ProcessedApplications.new(current_user).find)
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
end
