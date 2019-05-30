class EvidenceCheck < ActiveRecord::Base
  belongs_to :application, required: true
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true

  validates :expires_at, presence: true
end
