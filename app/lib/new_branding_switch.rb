module NewBrandingSwitch
  extend ActiveSupport::Concern

  def self.changes_apply?
    Time.zone.now.in_time_zone('London') >= Settings.new_branding.new_branding_date
  end
end
