# Removes the request and response JSON kept with each DWP API call once it is
# older than Settings.dwp_api_calls_purge.months_ago. What the exports need
# stays on the benefit check. See CHANGELOG.md
class DwpApiCallsPurgeJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    log("Running DWP API calls purge at #{Time.zone.now.to_fs(:db)}")
    purged = purge_old_calls
    log("Finished DWP API calls purge at #{Time.zone.now.to_fs(:db)}, calls purged: #{purged}")
  end

  private

  def purge_old_calls
    purged = 0
    old_calls.in_batches do |calls|
      purged += calls.update_all(data: nil, request_params: kept_request_params_sql, purged_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
    end
    purged
  end

  # A claims request (it carries the effective date window) holds no personal
  # details and is kept whole; a match or citizen request is about the person and goes.
  def kept_request_params_sql
    Arel.sql("CASE WHEN request_params ? 'effective_from' THEN request_params ELSE NULL END")
  end

  def old_calls
    DwpApiCall.where(purged_at: nil).where('created_at <= ?', purge_before)
  end

  # Calls made before this are old enough to purge (6 months by default, see settings.yml)
  def purge_before
    months = Settings.dwp_api_calls_purge.months_ago.to_i
    months.months.ago
  end

  def log(message)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event(message)
    tc.flush
  end
end
