class BenefitCheckRerunJob < ApplicationJob
  queue_as :default

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

  # Reruns the checks that DwpMonitor counts as DWP failures (see
  # BenefitCheck.dwp_outage_failure?). The SQL excludes genuine DWP answers
  # (Yes/No/Undetermined) so the limit applies to candidate failures; the
  # predicate then excludes applicant-data problems, which a rerun cannot fix.
  def load_failed_checks
    recent_unresolved_checks.select(&:dwp_outage_failure?)
  end

  def recent_unresolved_checks
    BenefitCheck.where('benefit_checks.created_at between ? AND ?', 3.days.ago, Time.zone.now).
      where('dwp_result IS NULL OR dwp_result NOT IN (?)', BenefitCheck::NON_OUTAGE_RESULTS).
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
