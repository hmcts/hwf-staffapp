module HmrcPersonLoadable
  extend ActiveSupport::Concern

  def applicant
    @applicant ||= @application.applicant
  end

  def user_params
    {
      first_name: person_first_name,
      last_name: person_last_name,
      nino: person_ni_number,
      dob: person_dob&.strftime('%Y-%m-%d')
    }
  end

  def person_first_name
    @check_type == 'partner' ? applicant.partner_first_name : applicant.first_name
  end

  def person_last_name
    @check_type == 'partner' ? applicant.partner_last_name : applicant.last_name
  end

  def person_dob
    @check_type == 'partner' ? applicant.partner_date_of_birth : applicant.date_of_birth
  end

  def person_ni_number
    @check_type == 'partner' ? applicant.partner_ni_number : applicant.ni_number
  end

end
