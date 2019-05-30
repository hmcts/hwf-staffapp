class PartPayment < ActiveRecord::Base
  belongs_to :application
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User'

  validates :expires_at, presence: true
end
