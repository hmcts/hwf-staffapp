class Detail < ActiveRecord::Base
  belongs_to :application, optional: false, inverse_of: :detail
  belongs_to :jurisdiction, optional: true
  has_many :dev_notes, as: :notable, dependent: :destroy

  before_validation :nullify_blank_emergency_reason

  def nullify_blank_emergency_reason
    self.emergency_reason = nil if emergency_reason.blank?
  end
end
