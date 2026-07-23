require 'rails_helper'

RSpec.feature 'FREG fee search on the online application details page' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:jurisdictions) { create_list(:jurisdiction, 2) }
  let(:office) { create(:office, jurisdictions: jurisdictions) }
  let(:user) { create(:staff, office: office) }
  let(:online_application) { create(:online_application, :with_reference) }

  before { login_as user }

  context 'when fee search is enabled' do
    before do
      allow(Settings).to receive(:freg_enabled).and_return(true)
      visit "/online_applications/#{online_application.id}/edit"
    end

    scenario 'renders the fee search field the JS binds to' do
      expect(page).to have_field('fee_search')
    end

    scenario 'renders the message shown when no fee version covers the refund date' do
      expect(page).to have_css('#fee-date-not-found-message', text: 'Fee for this date was not found', visible: :all)
    end

    context 'when the online application is a refund' do
      let(:online_application) { create(:online_application, :with_reference, :with_refund) }

      scenario 'stamps the refund flag and date fee paid for the fee search JS' do
        search_field = page.find('#fee_search')
        aggregate_failures do
          expect(search_field['data-refund']).to eq('true')
          expect(search_field['data-date-fee-paid']).to eq(online_application.date_fee_paid.strftime('%Y-%m-%d'))
        end
      end
    end

    context 'when the online application is not a refund' do
      scenario 'stamps a false refund flag and no date fee paid' do
        search_field = page.find('#fee_search')
        aggregate_failures do
          expect(search_field['data-refund']).to eq('false')
          expect(search_field['data-date-fee-paid']).to be_nil
        end
      end
    end

    scenario 'gives the fee input the id freg.js expects' do
      expect(page).to have_field('application_fee')
    end

    scenario 'renders the hidden fields the JS populates' do
      aggregate_failures do
        expect(page).to have_css('#application_fee_code', visible: :all)
        expect(page).to have_css('#application_claim_amount', visible: :all)
        expect(page).to have_css('#application_fee_version_valid_from', visible: :all)
        expect(page).to have_css('#application_fee_entry_method', visible: :all)
        expect(page).to have_css('#fee_search_has_results', visible: :all)
      end
    end

    scenario 'error summary fee link points to the fee search box' do
      click_button 'Next'
      expect(page).to have_css('.govuk-error-summary')
      expect(page).to have_link('Enter a court or tribunal fee', href: '#fee_search')
    end

    scenario 'error summary non-fee links use the online_application prefix' do
      click_button 'Next'
      expect(page).to have_link('You must select a jurisdiction', href: '#online_application_jurisdiction_id')
    end

    scenario 'error summary date_received link points to the day input' do
      click_button 'Next'
      expect(page).to have_link(href: '#online_application_day_date_received')
    end
  end

  context 'when fee search is disabled' do
    before do
      allow(Settings).to receive(:freg_enabled).and_return(false)
      visit "/online_applications/#{online_application.id}/edit"
    end

    scenario 'does not render the fee search field' do
      expect(page).to have_no_field('fee_search')
    end

    scenario 'leaves the fee input with its default id' do
      aggregate_failures do
        expect(page).to have_field('online_application_fee')
        expect(page).to have_no_field('application_fee')
      end
    end
  end
end
