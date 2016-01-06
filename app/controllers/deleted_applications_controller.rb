class DeletedApplicationsController < ApplicationController
  include ProcessedViewsHelper

  def index
    authorize :application

    @applications = applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    assign_views
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def applications
    @applications ||= policy_scope(Query::DeletedApplications.new(current_user).find)
  end
end
