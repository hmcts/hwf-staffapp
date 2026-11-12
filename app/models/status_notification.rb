# Where the status emails are up to for one monitored service ('hmrc', later 'dwp') - see CHANGELOG.md
class StatusNotification < ActiveRecord::Base
  validates :service, presence: true, uniqueness: true

  def self.for(service)
    find_or_create_by!(service: service)
  end
end
