class FinanceReportsController < ApplicationController

  def index
  end

  def output_to_excel
    respond_to do |format|
      format.xlsx
    end
  end

  def processed_applications
    @applications = Query::ProcessedApplications.new(current_user).find.map do |application|
      Views::ApplicationList.new(application)
    end
    respond_to do |format|
      format.xlsx
    end
  end
end
