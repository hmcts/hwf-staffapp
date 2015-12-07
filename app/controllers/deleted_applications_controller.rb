class DeletedApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = Query::DeletedApplications.new(current_user).find.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    assign_views
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
end
