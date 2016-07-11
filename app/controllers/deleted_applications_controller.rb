class DeletedApplicationsController < ApplicationController
  include ProcessedViewsHelper

  def index
    authorize :application

    @applications = paginated_applications.map do |application|
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

  def paginated_applications
    @paginate ||= policy_scope(Query::DeletedApplications.new(current_user).find).
                  paginate(page: params[:page], per_page: 2)
  end
end
