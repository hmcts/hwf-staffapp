
CCMCC_OFFICE_ENTITY_CODE = 'DH403'.freeze

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

def application_details_digital_page
  @application_details_digital_page ||= ApplicationDetailsDigitalPage.new
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

def benefit_checker_page
  @benefit_checker_page ||= BenefitCheckerPage.new
end

def processed_applications_page
  @processed_applications_page ||= ProcessedApplicationsPage.new
end

def deleted_applications_page
  @deleted_applications_page ||= DeletedApplicationsPage.new
end

def waiting_for_evidence_applications_page
  @waiting_for_evidence_applications_page = WaitingForEvidenceApplicationsPage.new
end

def waiting_for_part_payment_applications_page
  @waiting_for_part_payment_applications_page = WaitingForPartPaymentApplicationsPage.new
end

def processed_application_instance_page
  @processed_application_instance_page ||= ProcessedApplicationInstancePage.new
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

def problem_with_evidence_page
  @problem_with_evidence_page ||= ProblemWithEvidencePage.new
end

def reason_for_rejecting_evidence_page
  @reason_for_rejecting_evidence_page ||= ReasonForRejectingEvidencePage.new
end

def part_payment_page
  @part_payment_page ||= PartPaymentPage.new
end

def part_payment_return_letter_page
  @part_payment_return_letter_page ||= PartPaymentReturnLetterPage.new
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

def change_user_details_page
  @change_user_details_page ||= ChangeUserDetailsPage.new
end

def profile_page
  @profile_page ||= ProfilePage.new
end

def staff_page
  @staff_page ||= StaffPage.new
end

def staff_details_page
  @staff_details_page ||= StaffDetailsPage.new
end

def office_page
  @office_page ||= OfficePage.new
end

def offices_page
  @offices_page ||= OfficesPage.new
end

def edit_banner_page
  @edit_banner_page ||= EditBannerPage.new
end

def feedback_page
  @feedback_page ||= FeedbackPage.new
end

def letter_template_page
  @letter_template_page ||= LetterTemplatePage.new
end

def new_letter_template_page
  @old_letter_template_page ||= NewLetterTemplatePage.new
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

def evidence_result_page
  @evidence_result_page ||= EvidenceResultPage.new
end

def evidence_confirmation_page
  @evidence_confirmation_page ||= EvidenceConfirmationPage.new
end

def evidence_income_page
  @evidence_income_page ||= EvidenceIncomePage.new
end

def hmrc_income_check_page
  @hmrc_income_check_page ||= HmrcIncomeCheckPage.new
end

def forbidden_page
  @forbidden_page ||= ForbiddenPage.new
end

def process_application_guide_page
  @process_application_guide_page ||= ProcessApplicationGuidePage.new
end

def evidence_checks_guide_page
  @evidence_checks_guide_page ||= EvidenceChecksGuidePage.new
end

def part_payments_guide_page
  @part_payments_guide_page ||= PartPaymentsGuidePage.new
end

def appeals_guide_page
  @appeals_guide_page ||= AppealsGuidePage.new
end

def suspected_fraud_guide_page
  @suspected_fraud_guide_page ||= SuspectedFraudGuidePage.new
end

def ho_evidence_check_page
  @ho_evidence_check_page ||= HoEvidenceCheckPage.new
end

def process_online_application_page
  @process_online_application_page ||= ProcessOnlineApplicationPage.new
end

def dwp_failed_applications_page
  @dwp_failed_applications_page ||= DwpFailedApplicationsPage.new
end

def court_graphs_page
  @court_graphs_page ||= CourtGraphsPage.new
end

def datashare_evidence_page
  @datashare_evidence_page ||= DatashareEvidencePage.new
end

def fee_status_page
  @fee_status_page ||= FeeStatusPage.new
end

def declaration_page
  @declaration_page ||= DeclarationPage.new
end

def children_page
  @children_page ||= ChildrenPage.new
end

def income_kind_applicant_page
  @income_kind_applicant ||= IncomeKindApplicantPage.new
end

def complete_processing
  if base_page.content.has_complete_processing_button?
    base_page.content.complete_processing_button.click
  end
end

def start_application
  sign_in_page.load_page
  sign_in_page.user_account
end

def sign_in_as_reader
  sign_in_page.load_page
  sign_in_page.reader_account
end

def sign_in_as_admin
  sign_in_page.load_page
  sign_in_page.admin_account
end

def sign_in_as_manager
  sign_in_page.load_page
  sign_in_page.manager_account
end

def sign_in_as_user
  sign_in_page.load_page
  sign_in_page.user_account
end

def sign_in_as_ccmcc_office_user
  ccmcc_office = FactoryBot.create(:office, entity_code: CCMCC_OFFICE_ENTITY_CODE)
  user = FactoryBot.create(:user, office: ccmcc_office)
  sign_in_page.load_page
  sign_in_page.sign_in_with user
end

def click_on_back_to_start
  base_page.content.wait_until_back_to_start_link_visible
  base_page.content.back_to_start_link.click
end

def click_on_back_to_list
  base_page.content.wait_until_back_to_list_link_visible
  base_page.content.back_to_list_link.click
end

# benefit application full outcome with paper evidence provided
def eligable_application(user)
  application = FactoryBot.create(:application, :processed_state, :benefit_type,
                                  decision_cost: 600, user: user, office: user.office, outcome: 'full',
                                  reference: "#{reference_prefix}-000001", children: nil, income: nil)
  application.applicant.update(title: 'Mr', first_name: 'John Christopher', last_name: 'Smith', ni_number: Settings.dwp_mock.ni_number_yes.last)
  application.detail.update(case_number: 'E71YX571', fee: 600)

  FactoryBot.create(:benefit_override, correct: true, application: application)
end

def ineligable_application(user)
  application = FactoryBot.create(:application_no_remission, :processed_state, fee: 300,
                                                                               decision_cost: 0, user: user, office: user.office,
                                                                               reference: "#{reference_prefix}-000002", children: 0)
  application.applicant.update(first_name: 'John Christopher', last_name: 'Smith')
  FactoryBot.create(:benefit_check, :yes_result, applicationable: application, user: user)
end

def create_multiple_applications(user)
  eligable_application(user)
  ineligable_application(user)
end

def complete_and_back_to_start
  complete_processing
  base_page.content.wait_until_back_to_start_link_visible
  click_on_back_to_start
end

def part_payment_application(user)
  application = FactoryBot.create(:application, :waiting_for_part_payment_state, :income_type,
                                  decision_cost: nil, amount_to_pay: 40, user: user, office: user.office, outcome: 'part',
                                  reference: "#{reference_prefix}-000001", children: 3, income: nil, dependents: true)

  application.applicant.update(title: 'Mr', first_name: 'John Christopher', last_name: 'Smith', ni_number: Settings.dwp_mock.ni_number_yes.last)
  application.detail.update(case_number: 'E71YX571', fee: 600, refund: false)

  FactoryBot.create(:part_payment, application: application)
end

def waiting_evidence_application_ni(user)
  application = FactoryBot.create(:application, :waiting_for_evidence_state, :income_type,
                                  decision_cost: 656.66, amount_to_pay: 0, user: user, office: user.office, outcome: 'full',
                                  reference: "#{reference_prefix}-000001", children: nil, income: nil)
  application.applicant.update(title: 'Mr', first_name: 'John Christopher', last_name: 'Smith', ni_number: Settings.dwp_mock.ni_number_yes.last)
  application.detail.update(case_number: 'E71YX571', fee: 656.66, refund: true)
end

def waiting_hmrc_evidence_application(user)
  application = FactoryBot.create(:application, :waiting_for_evidence_state, user: user, office: user.office)
  application.applicant.update(title: 'Mr', first_name: 'John Christopher', last_name: 'Smith', ni_number: Settings.dwp_mock.ni_number_yes.last)
  application.evidence_check.update(income_check_type: 'hmrc')
end

def ho_applicant
  application = FactoryBot.create(:application)
  application.applicant.update(title: 'Mr', first_name: 'John Christopher', last_name: 'Smith', ho_number: '1212-0001-0240-0490/01')
  @applicant = application.applicant
end

def refund_application_with_waiting_evidence(user)
  detail = FactoryBot.create(:complete_detail, case_number: 'E71YX571', fee: 656.66, refund: true)
  FactoryBot.create(:application, :waiting_for_evidence_state, :income_type, benefits: false,
                                                                             decision_cost: 656.66, amount_to_pay: 0, user: user, office: user.office, outcome: 'full',
                                                                             reference: "#{reference_prefix}-000001", children: nil, income: nil, applicant: @applicant, detail: detail)
end

def reference_prefix
  "PA#{Time.zone.now.strftime('%y')}"
end

def create_application_with_bad_request_result_with(user)
  application = FactoryBot.create(:application, :applicant_full, ni_number: Settings.dwp_mock.ni_number_no.first, office: user.office, user: user, detail_traits: [:post_ucd])
  FactoryBot.create(:benefit_check, :bad_request_result, applicationable: application, user: user)
  application.applicant
end

def stub_dwp_response_as_bad_request
  allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(
    Faraday::TimeoutError.new("Request Timeout")
  )
end

def stub_dwp_response_as_dwp_down_request
  allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(
    BenefitCheckers::BadRequestError.new({ error: "LSCBC998: Service unavailable." }.to_json)
  )
end

def stub_dwp_response_as_ok_request
  response = double('response', body: { benefit_checker_status: "Yes", confirmation_ref: 1234 }.to_json)
  allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(response)
end

def stub_dwp_response_as_not_eligible_request
  response = double('response', body: { benefit_checker_status: "No", confirmation_ref: 1234 }.to_json)
  allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(response)
end

def create_online_application(reference = nil)
  if reference.present?
    FactoryBot.create(:online_application, :benefits, :completed, reference: reference)
  else
    FactoryBot.create(:online_application, :with_reference, :benefits, :completed)
  end
end

def dwp_monitor_state_as(state)
  dwp = instance_double('DwpMonitor', state: state)
  DwpMonitor.stub(:new).and_return dwp
end

def click_reference_link
  reference_link = "#{reference_prefix}-000001"
  expect(page).to have_link(reference_link)
  click_link reference_link
end

def enable_feature_switch(feature_name)
  FeatureSwitching.create(feature_key: feature_name, enabled: true)
end

def update_legislation_value
  id = current_url[%r{/(\d+)/}, 1]
  Application.find(id).detail.update(calculation_scheme: FeatureSwitching::CALCULATION_SCHEMAS[1])
end
