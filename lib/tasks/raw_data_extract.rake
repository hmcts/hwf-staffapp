namespace :reports do

  desc 'Generate raw data extract for given time frame'
  task :raw_data_extract, [:start, :end] => :environment do |_t, args|
    from = Date.parse(args[:start])
    to = Date.parse(args[:end])

    if from < to
      start_date = { day: from.day, month: from.month, year: from.year }
      end_date = { day: to.day, month: to.month, end_date: to.year }
      report = Views::Reports::RawDataExport.new(start_date, end_date)
      report.to_zip
      puts "Report file generated raw_data-#{from}-#{to}.csv.zip"
    else
      puts 'Please call the report with following format:'
      puts 'rake "reports:raw_data_extract[2021-01-01, 2022-12-31]"'
    end
  end
end
