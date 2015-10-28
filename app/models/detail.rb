class Detail < ActiveRecord::Base
  belongs_to :application, required: true
  belongs_to :jurisdiction

  before_validation :nullify_blank_emergency_reason

  def nullify_blank_emergency_reason
    self.emergency_reason = nil if emergency_reason.blank?
  end
end
