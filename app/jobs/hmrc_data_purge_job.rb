class HmrcDataPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log_task_run
    purge_old_hmrc_data
  end

  private

  def purge_old_hmrc_data
    old_hmrc_checks.each do |check|
      check.update(income: nil, employment: nil, address: nil, tax_credit: nil, purged_at: Time.zone.now)
      log_purge_item(check.id)
    end
  end

  def old_hmrc_checks
    HmrcCheck.where(purged_at: nil).where('created_at <= ?', 6.months.ago)
  end

  def log_task_run
    tc = ApplicationInsights::TelemetryClient.new ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']
    tc.track_event("Running HMRC purge data script#{Time.zone.now.to_s(:db)}")
    tc.flush
  end

  def log_purge_item(hmrc_check_id)
    tc = ApplicationInsights::TelemetryClient.new ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']
    tc.track_event("Purging HMRC data check id:#{hmrc_check_id} at #{Time.zone.now.to_s(:db)}")
    tc.flush
  end

end
