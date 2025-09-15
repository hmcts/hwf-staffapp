class IncomeKindRefactorJob < ApplicationJob
  queue_as :urgent

  def perform
    enqueue_applications(Application, 'Application')
    enqueue_applications(OnlineApplication, 'OnlineApplication')
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
end
