class DecisionOverride < ActiveRecord::Base
  belongs_to :application, required: true
  belongs_to :user, -> { with_deleted }, required: true

  validates :reason, presence: true
end
