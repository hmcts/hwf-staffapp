require 'report_builder'

at_exit do
  time = Time.now.getutc

  ReportBuilder.configure do |config|
    config.input_path = 'features/cucumber-report/cucumber_report.json'
    config.report_path = 'features/cucumber-report/cucumber_report'
    config.report_types = [:html]
    config.report_tabs = %w[Overview Features Scenarios Errors]
    config.report_title = 'Cucumber test results'
    config.compress_images = false
    config.additional_info = { 'Project name' => 'Test', 'Platform' => '-', 'Report generated' => time }
  end

  ReportBuilder.build_report
end