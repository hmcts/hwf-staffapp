class Spotcheck < ActiveRecord::Base
  belongs_to :application, required: true

  validates :expires_at, presence: true
end
