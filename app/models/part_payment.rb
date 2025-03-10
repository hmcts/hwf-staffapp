class PartPayment < ActiveRecord::Base
  belongs_to :application
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true
  has_many :dev_notes, as: :notable, dependent: :destroy

  validates :expires_at, presence: true
end
