class FeedbackPage < BasePage
  section :content, '#content' do
    element :user_feedback_header, 'h1', text: 'Your feedback'
    element :admin_feedback_header, 'h1', text: 'Feedback received'
    element :welcome_feedback, 'p', text: 'We welcome all feedback. Your comments will help us improve the service.'
    element :email_us, 'p', text: 'If you have an urgent question or something isn’t working, please email'
    element :email, 'a', text: 'helpwithfees.feedback@digital.justice.gov.uk'
    element :very_good_radio, '.govuk-label', text: '5 - very good'
    element :no_help, '.govuk-label', text: 'No'
    element :send_feedback_button, 'input[value="Send feedback"]'
    element :notice, '.notice', text: 'Your feedback has been recorded'
    element :table_headers, '.govuk-table__row', text: 'User name Experience so far Ideas for improvement Rating score Help needed Office Created'
    element :user, 'a', text: 'user'
    elements :cell_item, '.govuk-table__cell'
  end

  def submit_new_feedback
    fill_in 'What is your experience of using the service so far?', with: 'Top quality experience'
    fill_in 'Do you have any ideas for how this service could be improved?', with: 'No it is perfect, well done'
    content.very_good_radio.click
    content.no_help.click
    content.send_feedback_button.click
  end

  def add_feedback_for_admin
    sign_in_page.load_page
    sign_in_page.sign_in
    sign_in_page.user_account
    navigation_page.navigation_link.feedback.click
    submit_new_feedback
    navigation_page.sign_out
  end
end
