class ProcessedApplicationsController < ApplicationController
  include Pundit
  before_action :authenticate_user!

  def index
    authorize :application

    @applications = applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    @overview = Views::ApplicationOverview.new(application)
    @result = Views::ApplicationResult.new(application)
  end

  private

  def applications
    @applications ||= policy_scope(Query::ProcessedApplications.new(current_user).find)
  end

  def application
    @application ||= Application.find(params[:id])
  end
end
