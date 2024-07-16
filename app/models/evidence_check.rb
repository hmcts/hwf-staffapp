class EvidenceCheck < ActiveRecord::Base
  belongs_to :application, optional: false
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true
  has_many :hmrc_checks, dependent: :destroy

  validates :expires_at, presence: true
  validates :application_id, uniqueness: true

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

  def hmrc?
    income_check_type == 'hmrc'
  end

  def hmrc_check
    hmrc_checks.applicant.order('created_at asc').last
  end
  alias applicant_hmrc_check hmrc_check

  def partner_hmrc_check
    hmrc_checks.partner.order('created_at asc').last
  end

end
