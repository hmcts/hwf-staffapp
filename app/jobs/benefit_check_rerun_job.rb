class BenefitCheckRerunJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    return unless should_it_run?
    rerun_failed_benefit_checks
    check_the_outcome_and_reschedule
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

  def check_the_outcome_and_reschedule
    return unless should_it_run?
    BenefitCheckRerunJob.delay(run_at: 15.minutes.from_now).perform_later
  end

  def should_it_run?
    DwpMonitor.new.state == 'offline'
  end
end
