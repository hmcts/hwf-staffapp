class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :office
  validates :user_id, :office_id, presence: true

end
