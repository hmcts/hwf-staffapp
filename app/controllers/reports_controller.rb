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

  def graphs
    authorize :report, :graphs?
    load_graph_data
  end

  def public
    authorize :report, :public?
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

  def load_graph_data
    @report_data = []
    Office.non_digital.each do |office|
      @report_data << {
        name: office.name,
        benefit_checks: BenefitCheck.by_office_grouped_by_type(office.id).checks_by_day
      }
    end
  end
end
