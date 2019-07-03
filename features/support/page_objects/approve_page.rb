class ApprovePage < BasePage
  section :content, '#content' do
    element :header, 'h2', text: 'Ask a manager'
  end

  def go_to_approve_page
    personal_details_page.submit_all_personal_details
    submit_fee_1001
  end
end
