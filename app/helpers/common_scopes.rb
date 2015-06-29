module CommonScopes
  extend ActiveSupport::Concern

  def self.included(model)
    model.instance_eval do
      scope :checks_by_day, lambda {
        group_by_day("#{name.pluralize.underscore}.created_at", format: "%d %b %y").
          where("#{name.pluralize.underscore}.created_at > ?", (Time.zone.today.-6.days)).count
      }
    end
  end
end
