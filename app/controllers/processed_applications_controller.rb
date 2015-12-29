class ProcessedApplicationsController < ApplicationController
  include Pundit
  before_action :authenticate_user!

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
    @form = Forms::Application::Delete.new(application)
    @form.update_attributes(delete_params)
    if @form.save
      ResolverService.new(application, current_user).delete
      flash[:notice] = 'The application has been deleted'
      redirect_to(action: :index)
    else
      assign_views
      render :show
    end
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
end
