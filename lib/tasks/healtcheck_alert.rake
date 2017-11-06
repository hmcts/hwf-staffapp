namespace :healtcheck_alert do
  desc "check DWP status and report if it's down"
  task report_dwp_offline_status: :environment do
    AlertNotifier.run!
  end
end
