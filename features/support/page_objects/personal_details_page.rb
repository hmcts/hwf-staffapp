# rubocop:disable Metrics/ClassLength
class PersonalDetailsPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/personal_informations}

  section :content, '#content' do
    element :header, 'h1', text: 'Personal details'
    element :application_first_name, '#application_first_name'
    element :dob_legend, 'legend', text: 'Date of birth'
    element :dob_hint, '.govuk-hint', text: 'For example, 31 3 1980'
    element :application_day_date_of_birth, '#application_day_date_of_birth'
    element :application_month_date_of_birth, '#application_month_date_of_birth'
    element :application_year_date_of_birth, '#application_year_date_of_birth'
    element :ni_label, '.govuk-label', text: 'National Insurance number'
    element :ni_hint, '.hint', text: 'Must be completed for benefits-based applications'
    element :application_ni_number, '#application_ni_number'
    element :ho_label, '.govuk-label', text: 'Home Office reference number'
    element :ho_hint, '.hint', text: 'Where provided, example L1234567 or L1234567/1 for a family member or 1111-2222-3333-4444 or 1111-2222-3333-4444/1 for a family'
    element :application_ho_number, '#application_ho_number'
    element :last_name_error, '.error', text: 'Enter the applicant\'s last name'
    element :last_name_too_short_error, '.error', text: 'Last name is too short (minimum is 2 characters)'
    element :invalid_date_of_birth_error, '.error', text: 'Enter a valid date of birth'
    element :dob_in_the_future_error, '.error', text: 'Applicant\'s date of birth cannot be in the future'
    element :invalid_ho_error, '.error', text: 'Enter a Home Office reference number in the correct format'
    element :martial_status_error, '.error', text: 'Select a marital status'
    element :martial_status_legend, 'legend', text: 'Select the applicant\'s marital status'
    element :status_single, 'label', text: 'Single'
    element :status_married, 'label', text: 'Married or living with someone and sharing an income'
    element :next, 'input[value="Next"]'
    section :guidance, '.guidance' do
      elements :guidance_header, 'h2'
      elements :guidance_text, 'p'
      elements :guidance_list, 'ul'
      elements :guidance_sub_heading, 'h3'
      elements :guidance_link, 'a'
    end
  end

  def full_name
    find_field('First and middle names', visible: false).set('John Christopher')
    find_field('Last name', visible: false).set('Smith')
  end

  def valid_dob
    content.application_day_date_of_birth.set '10'
    content.application_month_date_of_birth.set '02'
    content.application_year_date_of_birth.set '1986'
  end

  def valid_dob_under_15
    now = Time.zone.now
    content.application_day_date_of_birth.set now.day
    content.application_month_date_of_birth.set now.month
    content.application_year_date_of_birth.set now.year - 14
  end

  def valid_dob_over
    now = Time.zone.now
    content.application_day_date_of_birth.set now.day
    content.application_month_date_of_birth.set now.month
    content.application_year_date_of_birth.set now.year - 67
  end

  def valid_dob_exactly_15
    now = Time.zone.now
    content.application_day_date_of_birth.set now.day
    content.application_month_date_of_birth.set now.month
    content.application_year_date_of_birth.set now.year - 15
  end

  def valid_dob_exactly_16
    now = Time.zone.now
    content.application_day_date_of_birth.set now.day
    content.application_month_date_of_birth.set now.month
    content.application_year_date_of_birth.set now.year - 16
  end

  def in_the_future_dob
    tomorrow = Time.zone.tomorrow
    content.application_day_date_of_birth.set tomorrow.day
    content.application_month_date_of_birth.set tomorrow.month
    content.application_year_date_of_birth.set tomorrow.year
  end

  def valid_ni
    content.application_ni_number.set 'JR054008D'
  end

  def ni_for_no_benefit_check
    content.application_ni_number.set 'SN789654B'
  end

  def valid_ho
    content.application_ho_number.set '1212-0001-0240-0490/01'
  end

  def invalid_hos
    content.application_ho_number.set 'L123456'
    click_next
    content.application_ho_number.set 'L12345678/1'
  end

  def submit_required_personal_details
    fill_in 'First and middle names', with: 'John', visible: false
    fill_in 'Last name', with: 'Smith', visible: false
    valid_dob
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_required_personal_details_66
    fill_in 'First and middle names', with: 'John', visible: false
    fill_in 'Last name', with: 'Smith', visible: false
    valid_dob_over
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_all_personal_details_ni
    full_name
    valid_dob
    valid_ni
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_all_personal_details_ni_with_no_answer_for_benefits
    full_name
    valid_dob
    ni_for_no_benefit_check
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_all_personal_details_ni_16
    full_name
    valid_dob_exactly_16
    valid_ni
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_all_personal_details_ni_under_15
    full_name
    valid_dob_under_15
    valid_ni
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_all_personal_details_ni_exactly_15
    full_name
    valid_dob_exactly_15
    valid_ni
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def submit_all_personal_details_ho
    full_name
    valid_dob
    valid_ho
    content.wait_until_status_single_visible
    content.status_single.click
    click_next
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
# rubocop:enable Metrics/ClassLength
