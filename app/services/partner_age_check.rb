class PartnerAgeCheck

  def initialize(record)
    @record = record
    @application = Application.find(@record.application_id)
  end

  def verify
    if @record.threshold_exceeded?
      if married_and_under_61
        [true, false].include?(@record.over_61)
      else
        true
      end
    end
  end

  private

  def married_and_under_61
    @application.married? && @application.applicant_age < 61
  end
end
