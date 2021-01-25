namespace :power_bi do
  desc "get data for power BI and send them by email"
  task run: :environment do
    export = Views::Reports::PowerBiExport.new
    export.csv_export_to_zip
    ApplicationMailer.power_bi_export.deliver_now
    export.tidy_up
  rescue StandardError => e
    Raven.tags_context(task: "power_bi_export") do
      Raven.capture_message(e.message)
    end
    Rails.logger.debug "Error in power_bi export task: #{e.message}"
  end
end
