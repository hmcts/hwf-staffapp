class FeatureSwitching < ApplicationRecord
  # enabled attribute is false as default

  NEW_BAND_CALCUATIONS_ACTIVE_DATE = DateTime.parse('27-11-2023').freeze

  CALCULATION_SCHEMAS = [:prior_q4_23, :q4_23].freeze

  def self.active?(method_name, office = nil)
    feature = FeatureSwitching.where(feature_key: method_name.to_s, enabled: true)
    feature = feature.where('activation_time <= ? OR activation_time IS NULL', Time.zone.now)
    feature = feature.where(office_id: office.id) if office.is_a?(Office)
    feature = feature.last

    feature.present?
  end

  def self.subject_to_new_legislation?(received_and_refund_data)
    return false if received_and_refund_data.blank? || received_and_refund_data[:date_received].blank?

    if received_and_refund_data[:refund]
      received_and_refund_data[:date_fee_paid] >= NEW_BAND_CALCUATIONS_ACTIVE_DATE
    else
      received_and_refund_data[:date_received] >= NEW_BAND_CALCUATIONS_ACTIVE_DATE
    end
  end

  def self.calculation_scheme(received_and_refund_data)
    if subject_to_new_legislation?(received_and_refund_data)
      FeatureSwitching::CALCULATION_SCHEMAS[1]
    else
      FeatureSwitching::CALCULATION_SCHEMAS[0]
    end
  end
end
