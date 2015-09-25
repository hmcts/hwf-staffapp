class PartnerAgeCheck

  def initialize(record)
    @record = record
    @application = Application.find(@record.application_id)
  end

  def verify
    [true, false].include?(@record.over_61) if @record.threshold_exceeded?
  end
end
