require 'test_helper'

class HomeHelperTest < ActiveSupport::TestCase
  include HomeHelper
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
end
