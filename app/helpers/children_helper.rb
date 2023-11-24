module ChildrenHelper

  def age_band_value(key, application)
    band = application.children_age_band
    return 0 if band.blank?
    return 0 unless band.key?(key)

    application.children_age_band[key]
  end
end
