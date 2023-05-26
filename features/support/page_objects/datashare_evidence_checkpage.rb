class DatashareEvidencePage < BasePage
  section :content, '#content' do
    element :checking_header, 'h1', text: 'For HMRC income checking'
    element :checked_header, 'h1', text: 'HMRC income checked'
    element :check_income_details_header, 'h1', text: 'Check income details'
    element :application_complete_header, 'h1', text: 'Application complete'
    element :not_eligible_header, 'h2', text: 'Not eligible for help with fees'
    element :entitlement_error, 'li', text: 'Hmrc This application requires a paper evidence check due to issues with HMRC tax credit data.'

    def click_submit
      content.wait_until_submit_visible
      content.submit.click
    end

    def click_no_additional_income
      content.wait_until_no_additional_income_visible
      content.no_additional_income_click
    end

    def click_next
      content.wait_until_next_visible
      content.next.click
    end

    def click_complete_processing
      content.wait_until_complete_processing_visible
      content.complete_processing_click
    end
  end
end
