module ApplicationFormMacros
  include Warden::Test::Helpers

  def complete_page_as(page, persona, submit)
    send("complete_#{page}", persona)

    submit ||= false
    click_button 'Next' if submit
  end

  private

  def complete_personal_information(persona)
    fill_in 'application_last_name', with: persona.last_name
    fill_in 'application_date_of_birth', with: persona.date_of_birth
    fill_in 'application_ni_number', with: persona.ni_number if persona.ni_number.present?
    if persona.married
      choose 'application_married_true'
    else
      choose 'application_married_false'
    end
  end

  def complete_application_details(persona)
    fill_in 'application_fee', with: 300
    find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
    fill_in 'application_date_received', with: Time.zone.yesterday
    fill_in 'application_form_name', with: persona.form_name if persona.form_name.present?
    fill_in 'application_case_number', with: persona.case_number if persona.case_number.present?
  end
end
