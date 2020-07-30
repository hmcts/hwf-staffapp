namespace :rerun_benefit_checks do
  desc "if DWPMonitor says it's down rerun failed bc checks to bring it back"
  task perform_job: :environment do
    if DwpMonitor.new.state == 'offline'
      BenefitCheckRerunJob.perform_now
      Rails.logger.info("Rake task rerun_benefit_checks - rerun was triggered")
    else
      Rails.logger.info("Rake task rerun_benefit_checks - no rerun needed")
    end
  rescue StandardError => e
    Rails.logger.error("Rake task rerun_benefit_checks - failed: #{e.message}")
  end
end
