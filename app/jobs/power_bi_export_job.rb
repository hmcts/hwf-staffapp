class PowerBiExportJob < ReportFileJob
  queue_as :default

  def perform(export_type:, month:, user_id:)
    @user = User.find(user_id)
    @export_type = export_type
    @month = month
    @task_name = "PowerBiExport#{export_type}"
    log_task_run('start', @task_name)
    extract
    log_task_run('end', @task_name)
  end

  private

  def extract
    @export = build_export
    @export.to_zip

    store_zip_file("power_bi_export_#{@export_type}")
    send_email_notifications
  rescue StandardError => e
    report_error(e, 'power_bi_export')
  ensure
    @export.tidy_up if @export&.zipfile_path
  end

  def build_export
    case @export_type
    when '2' then Views::Reports::PowerBiExport2.new(@month)
    when '3' then Views::Reports::PowerBiExport3.new(@month)
    else Views::Reports::PowerBiExport1.new(@month)
    end
  end
end
