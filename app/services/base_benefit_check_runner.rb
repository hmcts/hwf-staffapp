class BaseBenefitCheckRunner
  attr_reader :date_data
  attr_reader :applicant

  def can_run?
    @applicant.last_name.present? &&
      @applicant.date_of_birth.present? &&
      @applicant.ni_number.present? &&
      benefit_check_date.present?
  end


  private

  def benefit_check_date
    if @date_data.date_fee_paid.present?
      @date_data.date_fee_paid
    elsif @date_data.date_received.present?
      @date_data.date_received
    end
  end

  def build_hash
    Base64.encode64 [@applicant.last_name,
                     @applicant.date_of_birth,
                     @applicant.ni_number,
                     benefit_check_date].to_s
  end


end