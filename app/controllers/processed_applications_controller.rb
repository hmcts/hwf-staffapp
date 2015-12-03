class ProcessedApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = Query::ProcessedApplications.new(current_user).find.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    @form = Forms::Application::Remove.new(application)
    assign_views
  end

  def update
    @form = Forms::Application::Remove.new(application)
    @form.update_attributes(remove_params)
    if @form.save
      flash[:notice] = 'The application has been removed'
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

  def assign_views
    @application = application
    @processed = Views::ProcessingDetails.new(application)
    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
  end

  def remove_params
    params.require(:application).permit(*Forms::Application::Remove.permitted_attributes.keys)
  end
end
