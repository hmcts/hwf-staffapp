require 'rails_helper'

# The partner rows sit under Personal details on every summary page, pre- and
# post-UCD. They depend only on the partner data, not on the applicant's NI
# number. See CHANGELOG.md
RSpec.feature 'Partner rows on every summary page' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  before do
    # Partner details without an applicant NI number are only kept when the DWP API is on.
    allow(Settings).to receive(:dwp_api_enabled).and_return(true)
    login_as user
  end

  pages = {
    'paper application summary' => ->(h, app) { h.application_summary_path(app) },
    'before evidence check' => ->(h, app) { h.evidence_path(h.completed_evidence_check(app)) },
    'after evidence check' => ->(h, app) { h.summary_evidence_path(h.completed_evidence_check(app)) },
    'before part payment' => ->(h, app) { h.part_payment_path(h.create(:part_payment_part_outcome, application: app)) },
    'after part payment' => ->(h, app) { h.summary_part_payment_path(h.create(:part_payment_part_outcome, application: app)) },
    'processed application' => ->(h, app) { h.processed_application_path(app) },
    'deleted application' => ->(h, app) { h.deleted_application_path(app) }
  }

  state_traits_for_page = {
    'paper application summary' => [],
    'before evidence check' => [:waiting_for_evidence_state],
    'after evidence check' => [:waiting_for_evidence_state],
    'before part payment' => [:waiting_for_part_payment_state],
    'after part payment' => [:waiting_for_part_payment_state],
    'processed application' => [:processed_state],
    'deleted application' => [:deleted_state]
  }

  { 'pre-UCD' => [], 'post-UCD' => [:post_ucd] }.each do |scheme, detail_traits|
    pages.each do |page_name, path_for|
      context "#{scheme} #{page_name} page" do
        let(:application) do
          create(:application_full_remission, *state_traits_for_page[page_name],
                 user: user, office: office, outcome: 'full', detail_traits: detail_traits)
        end

        scenario 'shows the partner details when the applicant has no NI number' do
          application.applicant.update(married: true, ni_number: nil,
                                       partner_first_name: 'Jane', partner_last_name: 'Doe',
                                       partner_date_of_birth: Date.new(1990, 2, 1),
                                       partner_ni_number: 'SN741369A')

          visit path_for.call(self, application)

          expect(page).to have_css('.govuk-summary-list__key', text: "Partner's full name")
          expect(page).to have_css('.govuk-summary-list__value', text: 'Jane Doe')
          expect(page).to have_css('.govuk-summary-list__key', text: "Partner's date of birth")
          expect(page).to have_css('.govuk-summary-list__value', text: '1 February 1990')
          expect(page).to have_css('.govuk-summary-list__key', text: "Partner's National Insurance number")
          expect(page).to have_css('.govuk-summary-list__value', text: 'SN 74 13 69 A')
        end

        scenario 'hides the rows when there are no partner details' do
          application.applicant.update(married: true,
                                       partner_first_name: nil, partner_last_name: nil,
                                       partner_date_of_birth: nil, partner_ni_number: nil)

          visit path_for.call(self, application)

          expect(page).to have_no_text("Partner's full name")
          expect(page).to have_no_text("Partner's date of birth")
          expect(page).to have_no_text("Partner's National Insurance number")
        end
      end
    end
  end

  def completed_evidence_check(application)
    application.evidence_check.tap { |check| check.update(correct: true, income: 100, outcome: 'full') }
  end
end
