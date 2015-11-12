class ProcessedApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = Query::ProcessedApplications.new(current_user).find.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    @application = Application.find(params[:id])
    @processed = Views::ProcessingDetails.new(@application)
    @overview = Views::ApplicationOverview.new(@application)
    @result = Views::ApplicationResult.new(@application)
  end
end
