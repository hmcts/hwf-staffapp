class DashboardPage < BasePage

  set_url('/')

  element :welcome_user, 'span', text: 'Welcome user'
  element :dwp_offline_banner, '.dwp-banner-offline', text: 'DWP checkerYou can’t check an applicant’s benefits. We’re investigating this issue.'
  element :dwp_online_banner, '.dwp-banner-online', text: 'DWP checkerYou can process benefits and income based applications.'
  element :help_with_fees_home, 'a', text: 'Help with fees'
  section :content, '#content' do
    element :alert_title, '.govuk-error-summary__title'
    element :alert_text, '.alert'
    element :look_up_button, 'input[value="Look up"]'
    element :start_now_button, 'input[value="Start now"]', visible: false
    element :in_progress_header, 'h3', text: 'In progress'
    element :processed_applications, 'a', text: 'Processed applications'
    elements :last_application, '.govuk-table__row'
    element :last_application_header, 'h3', text: 'Your last applications'
    element :last_application_link, 'a', text: '1'
    element :waiting_for_evidence_application_link, 'a', text: 'AB001-20-'
    element :waiting_for_evidence_application_link2, 'a', text: 'HWF-'
    element :waiting_for_evidence, '#waiting-for-evidence'
    element :waiting_for_part_payment, '#waiting-for-part-payment'
    element :updated_applications, '.updated_applications', text: 'Mr John Christopher Smith'
    element :deleted_applications, 'a', text: 'Deleted applications'
    element :online_search_reference, '#online_search_reference'
    element :process_when_back_online_heading, 'h3', text: 'Process when DWP is back online'
    element :pending_applications_link, 'a', class: 'dwp-failed-applications', text: 'Pending applications to be processed'
    element :search_button, 'input[value="Search"]', visible: false
    element :online_search_reference_error, 'label', text: 'Reference number is not recognised'
    element :find_application_error, 'label', text: 'No results found'
    element :total_graph, '#chart-1'
    element :time_of_day_graph, '#chart-2'
    element :view_offices, 'a', text: 'View offices'
    element :generate_reports_button, '.button', text: 'Generate reports'
    element :court_graphs, 'a', text: 'Court graphs'
  end

  def look_up_reference(reference)
    content.online_search_reference.set reference
    content.look_up_button.click
  end

  def look_up_invalid_reference
    content.online_search_reference.set 'invalid'
    content.look_up_button.click
  end

  def process_application
    content.start_now_button.click
  end

  def generate_reports
    content.generate_reports_button.click
  end

  def go_home
    help_with_fees_home.click
  end

  def click_look_up
    content.wait_until_look_up_button_visible
    content.look_up_button.click
  end
end
