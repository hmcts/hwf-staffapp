class Feedback < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }
  belongs_to :office
  validates :rating, presence: true
end
