# TODO: Make a validator out of this service
class PartnerAgeCheck

  def initialize(record, application)
    @record = record
    @application = application
  end

  def verify
    process_marital_status_and_age if threshold_exceeded?
  end

  private

  def threshold_exceeded?
    @record.min_threshold_exceeded?
  end

  def process_marital_status_and_age
    if married_and_under_61
      only_boolean_values_present?
    else
      true
    end
  end

  def married_and_under_61
    @application.married? && @application.applicant_age < 61
  end

  def only_boolean_values_present?
    [true, false].include?(@record.over_61)
  end
end
