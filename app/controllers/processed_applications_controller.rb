class ProcessedApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = Query::ProcessedApplications.new.find.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    @application = Application.find(params[:id])
    @overview = Views::ApplicationOverview.new(@application)
    @result = Views::ApplicationResult.new(@application)
  end
end
