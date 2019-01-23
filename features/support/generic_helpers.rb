module WaitUntil
  def self.wait_until(timeout = 10, message = nil, &block)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout, message: message)
    wait.until(&block)
  end
end

def base_page
  @base_page ||= BasePage.new
end

def sign_in_page
  @sign_in_page ||= SignInPage.new
end

def dashboard_page
  @dashboard_page ||= DashboardPage.new
end

def new_password_page
  @new_password_page ||= NewPasswordPage.new
end

def personal_details_page
  @personal_details_page ||= PersonalDetailsPage.new
end

def application_details_page
  @application_details_page ||= ApplicationDetailsPage.new
end

def savings_investments_page
  @savings_investments_page ||= SavingsInvestmentsPage.new
end

def benefits_page
  @benefits_page ||= BenefitsPage.new
end

def paper_evidence_page
  @paper_evidence_page ||= PaperEvidencePage.new
end

def summary_page
  @summary_page ||= SummaryPage.new
end

def confirmation_page
  @confirmation_page ||= ConfirmationPage.new
end

def next_page
  base_page.content.next_button.click
end

def start_application
  sign_in_page.load_page
  sign_in_page.user_account
  dashboard_page.process_application
end

def submit_required_personal_details
  personal_details_page.submit_required_information
end

def submit_fee_600
  application_details_page.submit_with_fee_600
end

def submit_fee_300
  application_details_page.submit_with_fee_300
end

def submit_savings_less_than
  savings_investments_page.submit_less_than
end

def submit_savings_more_than
  savings_investments_page.submit_more_than
  savings_investments_page.submit_exact_amount
end

delegate :submit_benefits_yes, to: :benefits_page

delegate :submit_evidence_yes, to: :paper_evidence_page

delegate :complete_processing, to: :summary_page

def go_to_summary_page
  start_application
  submit_required_personal_details
  submit_fee_600
  submit_savings_less_than
  submit_benefits_yes
  submit_evidence_yes
end

def go_to_confirmation_page
  go_to_summary_page
  complete_processing
end

delegate :back_to_start, to: :confirmation_page

def processed_eligable_application
  start_application
  submit_required_personal_details
  submit_fee_600
  submit_savings_less_than
  submit_benefits_yes
  submit_evidence_yes
  complete_processing
  back_to_start
end

def processed_ineligable_application
  dashboard_page.process_application
  submit_required_personal_details
  submit_fee_300
  submit_savings_more_than
  complete_processing
  back_to_start
end
