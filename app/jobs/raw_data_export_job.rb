class RawDataExportJob < ReportFileJob
  queue_as :default

  def perform(args)
    @user = User.find(args[:user_id])
    @from_date = args[:from]
    @to_date = args[:to]
    @task_name = 'RawDataExport'
    log_task_run('start', @task_name)
    extract_raw_data
    log_task_run('end', @task_name)
  end

  private

  def extract_raw_data
    @export = Views::Reports::RawDataExport.new(@from_date, @to_date)
    @export.to_zip

    store_zip_file('raw_data')
    send_email_notifications
  rescue StandardError => e
    report_error(e, 'raw_data')
  end

end
