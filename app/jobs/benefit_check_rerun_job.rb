class BenefitCheckRerunJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    return unless should_it_run?
    rerun_failed_benefit_checks
  end

  private

  def rerun_failed_benefit_checks
    load_failed_checks.each do |check|
      application = check.application
      BenefitCheckRunner.new(application).run
    end
  end

  def load_failed_checks
    BenefitCheck.where(error_message: ['500 Internal Server Error',
                                       'Server broke connection', 'LSCBC959: Service unavailable.'],
                       created_at: 3.days.ago..Time.zone.now).
      select('distinct(application_id)').limit(10)
  end

  def should_it_run?
    DwpMonitor.new.state == 'offline'
  end
end
