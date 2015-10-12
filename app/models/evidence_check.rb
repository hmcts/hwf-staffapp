class EvidenceCheck < ActiveRecord::Base
  belongs_to :application, required: true
  has_one :reason

  validates :expires_at, presence: true
end
