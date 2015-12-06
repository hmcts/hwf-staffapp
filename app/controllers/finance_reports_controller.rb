class FinanceReportsController < ApplicationController
  respond_to :xlsx

  def index
  end

  def output_to_excel
  end

  def processed_applications
    @applications = Query::ProcessedApplications.new(current_user).find.map do |application|
      Views::ApplicationList.new(application)
    end
  end
end
