class DeletedApplicationsController < ApplicationController
  before_action :authenticate_user!

  include ProcessedViewsHelper

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
end
