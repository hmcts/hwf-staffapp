namespace :reports do

  desc 'Generate a unique applicants per financial year'
  task :applicants, [:year_start, :year_end] => :environment do |_t, args|
    fy_start = args[:year_start].to_i
    fy_end = args[:year_end].to_i
    if fy_start > 2016 && fy_end > 2016 &&
       fy_start < fy_end
      report = Views::Reports::ApplicantsPerFyExport.new(fy_start, fy_end)
      report.to_zip
      puts "Report file generated applicants-#{fy_start}-#{fy_end}-fy.csv.zip"
    else
      puts 'Please call the report with following format:'
      puts 'rake reports:applicants[2021, 2022]'
    end
  end
end
