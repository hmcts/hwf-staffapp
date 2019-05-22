module ApplicationFormMacros
  include Warden::Test::Helpers

  def complete_page_as(page, application, submit)
    send("complete_#{page}", application)

    submit ||= false
    click_button 'Next' if submit
  end

  private

  def complete_personal_information(application)
    applicant = application.applicant
    fill_in 'application_last_name', with: applicant.last_name
    fill_in_dob(applicant.date_of_birth)
    fill_in 'application_ni_number', with: applicant.ni_number if applicant.ni_number.present?
    if applicant.married
      choose 'application_married_true'
    else
      choose 'application_married_false'
    end
  end

  def complete_application_details(application)
    detail = application.detail
    fill_in 'application_fee', with: 300
    find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
    date_received = Time.zone.yesterday
    fill_in 'application_day_date_received', with: date_received.day
    fill_in 'application_month_date_received', with: date_received.month
    fill_in 'application_year_date_received', with: date_received.year
    complete_application_details_optionals(detail)
  end

  def complete_application_details_optionals(detail)
    fill_in 'application_form_name', with: detail.form_name if detail.form_name.present?
    fill_in 'application_case_number', with: detail.case_number if detail.case_number.present?
  end

  def fill_in_dob(dob)
    fill_in 'application_day_date_of_birth', with: dob.day
    fill_in 'application_month_date_of_birth', with: dob.month
    fill_in 'application_year_date_of_birth', with: dob.year
  end
end
