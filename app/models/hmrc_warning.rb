# Admin switch over HmrcMonitor, the HMRC version of DwpWarning - see CHANGELOG.md
class HmrcWarning < ActiveRecord::Base
  before_create :only_one_record_allowed

  STATES = { online: 'online', offline: 'offline', default_checker: 'default_checker' }.freeze

  def self.use_default_check?
    return true if order(id: :desc).first.blank?

    order(id: :desc).first.check_state == STATES[:default_checker]
  end

  def self.state
    return if order(id: :desc).first.blank?
    order(id: :desc).first.check_state
  end

  # The state staff get: the admin's choice, or the monitor's when left on default
  def self.checker_state
    return HmrcMonitor.new.state if use_default_check?
    state
  end

  def self.checker_offline?
    checker_state == STATES[:offline]
  end

  private

  def only_one_record_allowed
    if HmrcWarning.count >= 1
      errors.add(:base, 'Only one HmrcWarning is allowed')
      throw :abort
    end

    true
  end
end
