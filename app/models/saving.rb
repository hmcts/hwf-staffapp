class Saving < ActiveRecord::Base
  belongs_to :application, optional: false, inverse_of: :saving
  has_many :dev_notes, as: :notable, dependent: :destroy
end
