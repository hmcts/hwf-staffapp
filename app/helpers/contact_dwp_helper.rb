module ContactDwpHelper

  def params
    {
      id: @check_item.our_api_token,
      ni_number: @check_item.ni_number,
      surname: @check_item.last_name.upcase,
      birth_date: applicants_date_of_birth,
      entitlement_check_date: process_check_date
    }
  end

  def applicants_date_of_birth
    date_to_return = @check_item.is_a?(BenefitCheck) ? @check_item.date_of_birth : @check_item.dob
    date_to_return.strftime('%Y%m%d')
  end

  def process_check_date
    check_date = @check_item.date_to_check ? @check_item.date_to_check : Time.zone.today
    check_date.strftime('%Y%m%d')
  end
end
