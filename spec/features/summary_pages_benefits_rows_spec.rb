require 'rails_helper'

# The Benefits section is the same on every summary page, pre- and post-UCD:
# "DWP check passed" is the DWP result, "Correct evidence provided" the staff
# paper evidence answer, shown only when the DWP check did not pass.
RSpec.feature 'Benefits rows on every summary page' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }

  before { login_as user }

  # Lambdas run in the example (h), where route helpers and factories exist.
  # The waiting_for_evidence_state trait already builds the evidence check.
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
                 user: user, office: office, benefits: true, application_type: 'benefit',
                 outcome: 'full', detail_traits: detail_traits)
        end

        scenario 'DWP said No and staff confirmed paper evidence: both rows' do
          create(:benefit_check, applicationable: application, dwp_result: 'No')
          create(:benefit_override, application: application, correct: true)

          visit path_for.call(self, application)

          expect(row('Benefits declared in application')).to have_text('Yes')
          expect(row('DWP check passed')).to have_text('No')
          expect(row('Correct evidence provided')).to have_text('Yes')
        end

        scenario 'DWP said Yes after an earlier no-evidence answer: DWP row only' do
          create(:benefit_override, application: application, correct: false)
          create(:benefit_check, applicationable: application, dwp_result: 'Yes')

          visit path_for.call(self, application)

          expect(row('DWP check passed')).to have_text('Yes')
          expect(page).to have_no_text('Correct evidence provided')
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
