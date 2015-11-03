class ProcessedApplicationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @applications = Query::ProcessedApplications.new.find.map do |application|
      Views::ApplicationList.new(application)
    end
  end
end
