class DecisionOverride < ActiveRecord::Base
  belongs_to :application, optional: false
  belongs_to :user, -> { with_deleted }, optional: false

  validates :reason, presence: true
end
