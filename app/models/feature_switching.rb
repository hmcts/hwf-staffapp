class FeatureSwitching < ApplicationRecord
  # enabled attribute is false as default

  def self.active?(method_name, office = nil)
    feature = FeatureSwitching.where(feature_key: method_name.to_s, enabled: true)
    feature = feature.where('activation_time <= ? OR activation_time IS NULL', Time.zone.now)
    feature = feature.where(office_id: office.id) if office.is_a?(Office)
    feature = feature.last

    feature.present?
  end
end
