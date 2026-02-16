require 'test_helper'

# rubocop:disable Metrics/ClassLength
class HomeHelperTest < ActiveSupport::TestCase
  include HomeHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  # Stub request for sort_link_helper tests
  def request
    url = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=desc#new_completed_search'
    Struct.new(:original_url).new(url)
  end

  # path_for_application_based_on_state

  test 'waiting_for_evidence standard returns evidence path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: nil)

    assert_equal "/evidence/#{evidence_check.id}", path_for_application_based_on_state(application)
  end

  test 'waiting_for_evidence hmrc type returns new hmrc path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: 'hmrc')

    assert_equal "/evidence_checks/#{evidence_check.id}/hmrc/new", path_for_application_based_on_state(application)
  end

  test 'waiting_for_evidence hmrc type with no hmrc check returns new hmrc path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: 'hmrc')

    assert_equal "/evidence_checks/#{evidence_check.id}/hmrc/new", path_for_application_based_on_state(application)
  end

  test 'waiting_for_evidence hmrc type with hmrc check returns existing hmrc path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: 'hmrc')
    hmrc_check = create(:hmrc_check, evidence_check: evidence_check)

    assert_equal "/evidence_checks/#{evidence_check.id}/hmrc/#{hmrc_check.id}",
                 path_for_application_based_on_state(application)
  end

  test 'waiting_for_evidence hmrc check with error_response returns new hmrc path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: 'hmrc')
    create(:hmrc_check, evidence_check: evidence_check, error_response: 'HMRC error')

    assert_equal "/evidence_checks/#{evidence_check.id}/hmrc/new", path_for_application_based_on_state(application)
  end

  test 'waiting_for_evidence partner hmrc check with error_response returns new hmrc path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: 'hmrc')
    create(:hmrc_check, evidence_check: evidence_check)
    create(:hmrc_check, evidence_check: evidence_check, check_type: 'partner', error_response: 'HMRC error')

    assert_equal "/evidence_checks/#{evidence_check.id}/hmrc/new", path_for_application_based_on_state(application)
  end

  test 'waiting_for_evidence partner hmrc check without error_response returns existing partner path' do
    application = create(:application, :waiting_for_evidence_state)
    evidence_check = application.evidence_check
    evidence_check.update(income_check_type: 'hmrc')
    hmrc_check = create(:hmrc_check, evidence_check: evidence_check)
    create(:hmrc_check, evidence_check: evidence_check, check_type: 'partner')

    assert_equal "/evidence_checks/#{evidence_check.id}/hmrc/#{hmrc_check.id}",
                 path_for_application_based_on_state(application)
  end

  test 'waiting_for_part_payment returns part payment path' do
    application = create(:application, :waiting_for_part_payment_state)
    part_payment = create(:part_payment, application: application)

    assert_equal "/part_payments/#{part_payment.id}", path_for_application_based_on_state(application)
  end

  test 'online application returns edit online application path' do
    online_application = create(:online_application)

    assert_equal "/online_applications/#{online_application.id}/edit",
                 path_for_application_based_on_state(online_application)
  end

  test 'created paper application returns personal informations path' do
    application = create(:application, state: :created)

    assert_equal "/applications/#{application.id}/personal_informations",
                 path_for_application_based_on_state(application)
  end

  # sort_link_class

  test 'sort_link_class returns sort_arrows when column does not match sort_by' do
    assert_equal 'sort_arrows', sort_link_class('name', 'first_name')
  end

  test 'sort_link_class returns sort_arrow_desc when column matches sort_by with no direction' do
    assert_equal 'sort_arrow_desc', sort_link_class('first_name', 'first_name')
  end

  test 'sort_link_class returns sort_arrow_asc when sort_to is desc' do
    assert_equal 'sort_arrow_asc', sort_link_class('first_name', 'first_name', 'desc')
  end

  test 'sort_link_class returns sort_arrow_desc when sort_to is asc' do
    assert_equal 'sort_arrow_desc', sort_link_class('first_name', 'first_name', 'asc')
  end

  # sort_link_helper

  test 'sort_link_helper replaces sort direction when sort param matches' do
    expected = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=asc#new_completed_search'

    assert_equal expected, sort_link_helper('first_name', 'first_name', 'desc')
  end

  test 'sort_link_helper does not replace sort direction when sort param does not match' do
    @sort_to = 'asc'
    @sort_by = 'first_name'
    expected = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=last_name&sort_to=asc#new_completed_search'

    assert_equal expected, sort_link_helper('last_name', 'first_name', 'asc')
  end

  # created_application_link - online branch

  test 'created application linked to online application returns online application path' do
    online_application = create(:online_application)
    application = create(:application, state: :created, online_application: online_application)

    assert_equal "/online_applications/#{online_application.id}",
                 path_for_application_based_on_state(application)
  end

  # formatted_results_count

  test 'formatted_results_count returns bold count with pluralized result label' do
    results = Struct.new(:total_entries).new(5)

    output = formatted_results_count(results)

    assert_includes output, '<b>5</b>'
    assert_includes output, 'results'
  end

  test 'formatted_results_count uses singular for one result' do
    results = Struct.new(:total_entries).new(1)

    output = formatted_results_count(results)

    assert_includes output, '<b>1</b>'
    assert_includes output, 'result'
  end

  # search_table_headers

  test 'search_table_headers returns expected columns' do
    expected = [:reference, :entered, :first_name, :last_name, :case_number, :fee, :remission, :completed]

    assert_equal expected, search_table_headers
  end

  # feedback_link

  test 'feedback_link returns feedback display path for admin' do
    @current_user = create(:admin_user)

    assert_equal '/feedback/display', feedback_link
  end

  test 'feedback_link returns feedback path for non-admin' do
    @current_user = create(:user)

    assert_equal '/feedback', feedback_link
  end

  # state_value

  test 'state_value returns DWP with warning class when dwp failed' do
    application = create(:application, :waiting_for_evidence_state)
    create(:benefit_check, applicationable: application,
                           dwp_result: 'BadRequest',
                           error_message: 'LSCBC error')

    output = state_value(application)

    assert_includes output, 'DWP'
    assert_includes output, 'red-warning-text'
  end

  test 'state_value returns waiting_for_evidence hmrc when hmrc check link' do
    application = create(:application, :waiting_for_evidence_state)
    application.evidence_check.update(income_check_type: 'hmrc')

    output = state_value(application)

    assert_includes output, 'waiting_for_evidence hmrc'
  end

  test 'state_value returns application state by default' do
    application = create(:application, :processed_state)

    output = state_value(application)

    assert_includes output, 'processed'
  end

  # dwp_failed

  test 'dwp_failed returns true when last benefit check has dwp error' do
    application = create(:application)
    create(:benefit_check, applicationable: application,
                           dwp_result: 'BadRequest',
                           error_message: 'LSCBC error')

    assert dwp_failed(application)
  end

  test 'dwp_failed returns nil when no benefit checks' do
    application = create(:application)

    assert_nil dwp_failed(application)
  end

  # td_line_state

  test 'td_line_state returns td tag with message' do
    output = td_line_state('processed')

    assert_includes output, '<td'
    assert_includes output, 'govuk-table__cell'
    assert_includes output, 'processed'
  end

  test 'td_line_state includes custom class when provided' do
    output = td_line_state('DWP', ' red-warning-text')

    assert_includes output, 'govuk-table__cell red-warning-text'
  end

  # dwp_pending_office

  test 'dwp_pending_office returns office name from record' do
    office = create(:office, name: 'Bristol')
    application = create(:application, office: office)

    assert_equal 'Bristol', dwp_pending_office(application)
  end

  test 'dwp_pending_office returns user office name when record has no office' do
    office = create(:office, name: 'Leeds')
    user = create(:user, office: office)
    online_application = create(:online_application, user: user)

    assert_equal 'Leeds', dwp_pending_office(online_application)
  end

  private

  attr_reader :current_user
end
# rubocop:enable Metrics/ClassLength
