class PartnerAgeCheck

  def initialize(record)
    @record = record
    @application = Application.find(@record.application_id)
  end

  def verify
    if @record.threshold_exceeded?
      [true, false].include?(@record.over_61) ? @record.over_61 : false
    end
  end
end
