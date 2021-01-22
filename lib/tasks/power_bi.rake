namespace :power_bi do
  desc "get data for power BI and send them by email"
  task run: :environment do
    export = Views::Reports::PowerBiExport.new
    export.csv_export_to_zip
    export.tidy_up
  end
end
