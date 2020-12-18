class Feedback < ActiveRecord::Base
  belongs_to :user, -> { with_deleted }
  belongs_to :office
  validates :user_id, :office_id, presence: true
  validates :rating, presence: true
end
