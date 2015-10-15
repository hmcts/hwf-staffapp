class Payment < ActiveRecord::Base
  belongs_to :application

  validates :expires_at, presence: true
end
