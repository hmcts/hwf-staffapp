namespace :rerun_benefit_checks do
  desc "if DWPMonitor says it's down rerun failed bc checks to bring it back"
  task perform_job: :environment do
    if DwpMonitor.new.state == 'offline'
      BenefitCheckRerunJob.perform_now
    end
  end
end
