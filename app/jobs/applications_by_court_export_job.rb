class ApplicationsByCourtExportJob < ReportFileJob
  queue_as :default

  def perform(args)
    @court_id = args[:court_id]
    @user = User.find(args[:user_id])
    @from_date = args[:from]
    @to_date = args[:to]
    @task_name = 'ApplicationsByCourtExport'
    @all_offices = args[:all_offices]
    log_task_run('start', @task_name)
    extract
    log_task_run('end', @task_name)
  end

  private

  def extract
    @export = Views::Reports::ApplicationsByCourtExport.new(@from_date, @to_date, @court_id,
                                                            all_offices: @all_offices)
    @export.to_zip

    store_zip_file('ApplicationsByCourt')

    send_email_notifications
  rescue StandardError => e
    report_error(e, 'ApplicationsByCourt')
  end

end
