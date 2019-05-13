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

    event = GtmOnRails::DataLayer::Event.new(
        'Application tracking',
        medium:           application.medium || 'NA',
        type:             application.application_type || 'NA',
        office_id:        current_user.office.id,
        jurisdiction_id:  application.detail.jurisdiction_id || 'NA',
        rails_controller: controller_name,
        rails_action:     action_name
      )
    data_layer.push(event)
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def paginated_applications
    @paginate ||= paginate(policy_scope(Query::DeletedApplications.new(current_user).find))
  end
end
