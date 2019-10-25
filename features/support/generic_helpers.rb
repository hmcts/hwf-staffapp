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

def approve_page
  @approve_page ||= ApprovePage.new
end

def find_application_page
  @find_application_page ||= FindApplicationPage.new
end

def application_page
  @application_page ||= ApplicationPage.new
end

def processed_applications_page
  @processed_applications_page ||= ProcessedApplicationsPage.new
end

def savings_investments_page
  @savings_investments_page ||= SavingsInvestmentsPage.new
end

def benefits_page
  @benefits_page ||= BenefitsPage.new
end

def incomes_page
  @incomes_page ||= IncomesPage.new
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

def generate_report_page
  @generate_report_page ||= GenerateReportPage.new
end

def feedback_page
  @feedback_page ||= FeedbackPage.new
end

def reports_page
  @reports_page ||= ReportsPage.new
end

def guide_page
  @guide_page ||= GuidePage.new
end

def dwp_message_page
  @dwp_message_page ||= DwpMessagePage.new
end

def navigation_page
  @navigation_page ||= NavigationPage.new
end

def evidence_accuracy_page
  @evidence_accuracy_page ||= EvidenceAccuracyPage.new
end

def return_letter_page
  @return_letter_page ||= ReturnLetterPage.new
end

def evidence_page
  @evidence_page ||= EvidencePage.new
end

def next_page
  base_page.content.next_button.click
end

def start_application
  sign_in_page.load_page
  sign_in_page.user_account
  dashboard_page.process_application
end

def go_to_finance_transactional_report_page
  visit(reports_page.url)
  reports_page.finance_transactional_report
end

def back_to_start
  confirmation_page.back_to_start
end

def complete_processing
  base_page.content.complete_processing_button.click
end

def eligable_application
  personal_details_page.submit_all_personal_details
  application_details_page.submit_fee_600
  savings_investments_page.submit_less_than
  benefits_page.submit_benefits_yes
  paper_evidence_page.submit_evidence_yes
  complete_processing
  back_to_start
end

def ineligable_application
  personal_details_page.submit_required_personal_details
  application_details_page.submit_fee_300
  savings_investments_page.submit_exact_amount
  complete_processing
  back_to_start
end

def multiple_applications
  eligable_application
  dashboard_page.process_application
  ineligable_application
end

def part_payment_application
  dashboard_page.process_application
  personal_details_page.submit_all_personal_details
  application_details_page.submit_fee_600
  savings_investments_page.submit_less_than
  benefits_page.submit_benefits_no
  incomes_page.submit_incomes_no_1200
  complete_processing
  back_to_start
end

def waiting_evidence_application
  dashboard_page.process_application
  personal_details_page.submit_all_personal_details
  application_details_page.submit_as_refund_case
  savings_investments_page.submit_less_than
  benefits_page.submit_benefits_no
  incomes_page.submit_incomes_no_50
  complete_processing
  back_to_start
end
