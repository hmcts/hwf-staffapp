class UpdateIncomeKindJob < ApplicationJob
  queue_as :urgent

  def perform(application_id, type)
    application = type.constantize.find_by(id: application_id)
    return if application.blank? || application.income_kind.blank?

    IncomeKindRefactorService.new(application, type).call
  end
end
