class ReportsController < ApplicationController
  before_action :authorise_report_show, except: [:index, :graphs, :public, :letters, :new_letters]

  def index
    authorize :report
  end

  def finance_transactional_report
    @form = Forms::Report::FinanceTransactionalReport.new
  end

  def finance_transactional_report_generator
    @form = ftr_form
    if @form.valid?
      finance_transactional_delay_job
      flash[:notice] = I18n.t('.forms/report/fi_transactional.notice')
      redirect_to reports_path
    else
      render :finance_transactional_report
    end
  end

  def finance_report
    @form = Forms::FinanceReport.new
  end

  def finance_report_generator
    @form = form
    if @form.valid?
      build_and_return_data(finance_report_builder.to_csv, 'finance-report')
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
    @data = Views::Reports::PublicSubmissionData.new
  end

  def letters
    authorize :report, :letter?
  end

  def new_letters
    authorize :report, :letter?
  end

  private

  def finance_transactional_delay_job
    from_date = date_from(ftr_params)
    to_date = date_to(ftr_params)
    user_id = current_user.id
    FinanceTransactionalReportJob.perform_later(from: from_date, to: to_date, user_id: user_id,
                                                filter: filters(ftr_params))
  end

  def form
    Forms::FinanceReport.new(report_params)
  end

  def report_params
    form_params(:forms_finance_report)
  end

  def ftr_form
    Forms::Report::FinanceTransactionalReport.new(ftr_params)
  end

  def ftr_params
    form_params(:forms_report_finance_transactional_report)
  end

  def form_params(form_name)
    params.require(form_name).
      permit(:day_date_from, :month_date_from, :year_date_from, :day_date_to,
             :month_date_to, :year_date_to, :sop_code, :refund, :application_type, :jurisdiction_id, :entity_code,
             :all_offices)
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

  def build_and_return_data(data_set, prefix)
    send_data data_set,
              filename: "#{prefix}-#{@form.start_date}-#{@form.end_date}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  end

  def filters(form_params)
    filters = {}

    ['sop_code', 'refund', 'application_type', 'jurisdiction_id'].each do |key|
      filters[key.to_sym] = form_params[key] if form_params[key].present?
    end
    filters
  end

  def finance_report_builder
    FinanceReportBuilder.new(
      date_from(report_params), date_to(report_params),
      filters(report_params)
    )
  end

  def date_from(params_type)
    { day: params_type[:day_date_from],
      month: params_type[:month_date_from],
      year: params_type[:year_date_from] }
  end

  def date_to(params_type)
    { day: params_type[:day_date_to],
      month: params_type[:month_date_to],
      year: params_type[:year_date_to] }
  end

  def authorise_report_show
    authorize :report, :show?
  end
end
