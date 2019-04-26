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

def application_search_page
  @application_search_page ||= ApplicationSearchPage.new
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

def processed_eligable_application
  start_application
  personal_details_page.submit_all_personal_details
  application_details_page.submit_fee_600
  savings_investments_page.submit_less_than
  benefits_page.submit_benefits_yes
  paper_evidence_page.submit_evidence_yes
  summary_page.complete_processing
  back_to_start
end

def processed_ineligable_application
  dashboard_page.process_application
  personal_details_page.submit_required_personal_details
  application_details_page.submit_fee_300
  savings_investments_page.submit_exact_amount
  summary_page.complete_processing
  back_to_start
end
