class FeedbackPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Your feedback'
    element :very_good_radio, '.govuk-label', text: '5 - very good'
    element :no_help, '.govuk-label', text: 'No'
    element :send_feedback_button, 'input[value="Send feedback"]'
    element :notice, '.notice', text: 'Your feedback has been recorded'
  end

  def submit_new_feedback
    fill_in 'What is your experience of using the service so far?', with: 'Top quality experience'
    fill_in 'Do you have any ideas for how this service could be improved?', with: 'No it is perfect, well done'
    content.very_good_radio.click
    content.no_help.click
    content.send_feedback_button.click
  end
end
