class FinanceTransactionalReportJob < ReportFileJob
  queue_as :default

  def perform(args)
    @user = User.find(args[:user_id])
    @from_date = args[:from]
    @to_date = args[:to]
    @filters = args[:filters] || {}
    @task_name = 'Finance Transactional'
    log_task_run('start', @task_name)
    extract_finance_transactional_report
    log_task_run('end', @task_name)
  end

  private

  def extract_finance_transactional_report
    @export = FinanceTransactionalReportBuilder.new(@from_date, @to_date, @filters)
    @export.to_zip

    store_zip_file('finance_transactional')
    send_email_notifications
  rescue StandardError => e
    report_error(e, 'financial_export')
  end

end
