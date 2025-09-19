class IncomeKindRefactorJob < ApplicationJob
  queue_as :urgent

  def perform
    log_task_run('start', 'Application Refactoring')
    enqueue_applications(Application, 'Application')
    log_task_run('end', 'Application Refactoring')
    log_task_run('start', 'OnlineApplication Refactoring')
    enqueue_applications(OnlineApplication, 'OnlineApplication')
    log_task_run('end', 'OnlineApplication Refactoring')
  end

  def self.run_recent_records_sync # rubocop:disable Metrics/MethodLength
    till_date = 5.months.ago

    Application.where("created_at >= ? OR updated_at >= ?", till_date, till_date).
      where.not(income_kind: [nil, '', {}]).
      find_each(batch_size: 100) do |application|
      IncomeKindRefactorService.new(application, 'Application').call
    end

    OnlineApplication.where("created_at >= ? OR updated_at >= ?", till_date, till_date).
      where.not(income_kind: [nil, '', {}]).
      find_each(batch_size: 100) do |online_application|
      IncomeKindRefactorService.new(online_application, 'OnlineApplication').call
    end
  end # rubocop:enable Metrics/MethodLength

  private

  def enqueue_applications(scope, type)
    scope.where.not(income_kind: [nil, {}, '']).in_batches(of: 500) do |batch|
      batch.each do |application|
        UpdateIncomeKindJob.perform_later(application.id, type)
      end
    end
  end

  def log_task_run(event, name)
    tc = ApplicationInsights::TelemetryClient.new ENV.fetch('AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY', nil)
    tc.track_event("Running #{name} #{event} at #{Time.zone.now.to_fs(:db)}")
    tc.flush
  end
end
