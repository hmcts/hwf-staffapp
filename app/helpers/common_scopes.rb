module CommonScopes
  extend ActiveSupport::Concern

  def self.included(model)
    model.instance_eval do
      scope :checks_by_day, lambda {
        model_name = name.pluralize.underscore
        group_by_day("#{model_name}.created_at", format: "%d %b %y").
          where("#{model_name}.created_at > ?", (Time.zone.today.-6.days)).count
      }
    end
  end
end
