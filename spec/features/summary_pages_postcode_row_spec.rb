require 'rails_helper'

# The UK postcode row sits under Personal details on every summary page,
# pre- and post-UCD, and is shown only when the applicant has a postcode.
RSpec.feature 'UK postcode row on every summary page' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  before { login_as user }

  pages = {
    'before evidence check' => ->(h, app) { h.evidence_path(h.completed_evidence_check(app)) },
    'after evidence check' => ->(h, app) { h.summary_evidence_path(h.completed_evidence_check(app)) },
    'before part payment' => ->(h, app) { h.part_payment_path(h.create(:part_payment_part_outcome, application: app)) },
    'after part payment' => ->(h, app) { h.summary_part_payment_path(h.create(:part_payment_part_outcome, application: app)) },
    'processed application' => ->(h, app) { h.processed_application_path(app) },
    'deleted application' => ->(h, app) { h.deleted_application_path(app) }
  }

  state_for_page = {
    'before evidence check' => :waiting_for_evidence_state,
    'after evidence check' => :waiting_for_evidence_state,
    'before part payment' => :waiting_for_part_payment_state,
    'after part payment' => :waiting_for_part_payment_state,
    'processed application' => :processed_state,
    'deleted application' => :deleted_state
  }

  { 'pre-UCD' => [], 'post-UCD' => [:post_ucd] }.each do |scheme, detail_traits|
    pages.each do |page_name, path_for|
      context "#{scheme} #{page_name} page" do
        let(:application) do
          create(:application_full_remission, state_for_page[page_name],
                 user: user, office: office, outcome: 'full', detail_traits: detail_traits)
        end

        scenario 'shows the postcode when the applicant has one' do
          application.applicant.update(postcode: 'SW1H 9AJ')

          visit path_for.call(self, application)

          expect(row('UK postcode')).to have_text('SW1H 9AJ')
        end

        scenario 'hides the row when there is no postcode' do
          visit path_for.call(self, application)

          expect(page).to have_no_text('UK postcode')
        end
      end
    end
  end

  def completed_evidence_check(application)
    application.evidence_check.tap { |check| check.update(correct: true, income: 100, outcome: 'full') }
  end

  def row(label)
    find(:xpath, "//dt[normalize-space()='#{label}']/following-sibling::dd[1]")
  end
end
