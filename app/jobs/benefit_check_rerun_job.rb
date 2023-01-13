class BenefitCheckRerunJob < ApplicationJob
  queue_as :default
  DWP_ERROR_MESSAGES = ['500 Internal Server Error',
                        'Server broke connection',
                        'LSCBC959: Service unavailable.',
                        'LSCBC958: Service unavailable.',
                        'The benefits checker is not available at the moment. Please check again later.'].freeze

  def perform(*_args)
    log_task_run
    return unless should_it_run?
    rerun_failed_benefit_checks
  end

  private

  def rerun_failed_benefit_checks
    load_failed_checks.each do |check|
      application = check.applicationable
      next if application.is_a?(Application) && application.state != 'created'
      rerun_online(application) if application.is_a?(OnlineApplication)
      rerun_paper(application) if application.is_a?(Application)
    end
  end

  def rerun_online(application)
    OnlineBenefitCheckRunner.new(application).run
  end

  def rerun_paper(application)
    BenefitCheckRunner.new(application).run
  end

  def load_failed_checks
    BenefitCheck.where('benefit_checks.created_at between ? AND ?', 3.days.ago, Time.zone.now).
      where(error_message: DWP_ERROR_MESSAGES).
      select('distinct on (applicationable_id, applicationable_type) *').order(:applicationable_id).limit(100)
  end

  def should_it_run?
    DwpMonitor.new.state == 'offline'
  end

  def log_task_run
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running rerun_benefit_checks #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end

end
