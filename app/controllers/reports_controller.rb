class ReportsController < ApplicationController
  def index
    authorize :report
  end

  def finance_report
    authorize :report, :show?
    @form = Forms::FinanceReport.new
  end

  def finance_report_generator
    authorize :report, :show?
    @form = form
    if @form.valid?
      send_data FinanceReportBuilder.new(report_params[:date_from], report_params[:date_to]).to_csv,
        filename: "finance-report-#{@form.start_date}-#{@form.end_date}.csv",
        type: 'text/csv',
        disposition: 'attachment'
    else
      render :finance_report
    end
  end

  private

  def form
    Forms::FinanceReport.new(
      date_from: report_params[:date_from],
      date_to: report_params[:date_to]
    )
  end

  def report_params
    params.require(:forms_finance_report).permit(:date_from, :date_to)
  end
end
