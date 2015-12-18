class OutputsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :access, :outputs
  end

  def finance_report
    authorize! :access, :outputs
    @form = Forms::FinanceReport.new
  end

  def finance_report_generator
    authorize! :access, :outputs
    @date_from = Date.parse(report_params[:date_from])
    @date_to = Date.parse(report_params[:date_to])
    @data = FinanceReportBuilder.new(report_params[:date_from], report_params[:date_to])
    send_data @data.to_csv, filename: "finance-report-#{@date_from}-#{@date_to}.csv"
  end

  private

  def report_params
    params.require(:forms_finance_report).permit(:date_from, :date_to)
  end
end
