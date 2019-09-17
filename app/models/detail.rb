class Detail < ActiveRecord::Base
  belongs_to :application, required: true, inverse_of: :detail
  belongs_to :jurisdiction, optional: true

  before_validation :nullify_blank_emergency_reason

  def nullify_blank_emergency_reason
    self.emergency_reason = nil if emergency_reason.blank?
  end
end
