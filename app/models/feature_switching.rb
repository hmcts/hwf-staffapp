class FeatureSwitching < ApplicationRecord
  # enabled attribute is false as default

  NEW_BAND_CALCUATIONS_ACTIVE_DATE = DateTime.parse(Settings.legislation_work.active_date).freeze

  CALCULATION_SCHEMAS = [:prior_q4_23, :q4_23].freeze

  def self.active?(method_name, office = nil)
    feature = FeatureSwitching.where(feature_key: method_name.to_s, enabled: true)
    feature = feature.where('activation_time <= ? OR activation_time IS NULL', Time.zone.now)
    feature = feature.where(office_id: office.id) if office.is_a?(Office)
    feature = feature.order(id: :desc).first

    feature.present?
  end

  def self.subject_to_new_legislation?(received_and_refund_data)
    return false if correct_dates(received_and_refund_data)

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

  def self.correct_dates(data)
    data[:date_received].blank? || !data[:date_received].is_a?(Date) ||
      (data[:refund] && !data[:date_fee_paid].is_a?(Date))
  end
end
