class EvidenceCheck < ActiveRecord::Base
  belongs_to :application, optional: false
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true

  validates :expires_at, presence: true

  serialize :incorrect_reason_category

  def clear_incorrect_reason!
    self.incorrect_reason = nil
    self.income = nil
    save
  end

  def clear_incorrect_reason_category!
    self.incorrect_reason_category = nil
    self.staff_error_details = nil
    save
  end
end
