class OcmcExportJob < ReportFileJob
  queue_as :default

  def perform(args)
    @court_id = args[:court_id]
    @user = User.find(args[:user_id])
    @from_date = args[:from]
    @to_date = args[:to]
    @task_name = 'OCMCExport'
    @all_offices = args[:all_offices]
    log_task_run('start', @task_name)
    extract
    log_task_run('end', @task_name)
  end

  private

  def extract
    @export = Views::Reports::HmrcOcmcDataExport.new(@from_date, @to_date, @court_id,
                                                     all_offices: @all_offices)
    @export.to_zip

    store_zip_file('OCMC')

    send_email_notifications
  rescue StandardError => e
    report_error(e, 'OCMC')
  end

end
