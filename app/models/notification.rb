class Notification < ActiveRecord::Base
  validate :only_one_record_allowed, on: :create
  validates :show, inclusion: [true, false]

  private

  def only_one_record_allowed
    if Notification.count >= 1
      errors.add(:base, 'Only one notification is allowed')
      return false
    end

    true
  end
end
