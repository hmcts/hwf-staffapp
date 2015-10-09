require 'rails_helper'

RSpec.feature 'Evidence check flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_full_remission, user: user }
  let(:outcome) { nil }
  let(:amount) { nil }
  let!(:evidence) { create :evidence_check, application_id: application.id, outcome: outcome, amount_to_pay: amount }

  before { login_as user }

  context 'when on "Evidence show" page' do
    before { visit evidence_show_path(id: evidence.id) }
    headings = ['Waiting for evidence',
                'Process evidence',
                'Processing details',
                'Personal details',
                'Application details',
                'Assessment']

    headings.each do |heading_title|
      it "has a heading titled #{heading_title}" do
        expect(page).to have_content heading_title
      end
    end

    scenario 'when clicked on "Next", goes to the next page' do
      click_link 'Next'
      expect(page).to have_content 'Is the evidence correct?'
    end
  end

  context 'when on "Evidence accuracy" page' do
    before { visit evidence_accuracy_path(id: evidence.id) }

    context 'when the page is submitted without anything filled in' do
      before { click_button 'Next' }

      it 're-renders the page' do
        expect(page).to have_content 'Is the evidence correct?'
      end
    end

    it 'displays the title of the page' do
      expect(page).to have_content 'Evidence'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the evidence correct?'
    end

    scenario 'fill in the form takes me to the income page' do
      choose 'evidence_correct_false'
      expect(page).to have_content 'What is incorrect about the evidence?'
      click_button 'Next'
      expect(page).to have_content 'Total monthly income from evidence'
    end
  end

  context 'when on "Income" page' do
    before { visit evidence_income_path(id: evidence.id) }

    it 'fill in the income form takes me to the next page' do
      expect(page).to have_content 'Total monthly income from evidence'
      fill_in 'evidence_amount', with: 500
      click_button 'Next'
    end
  end

  context 'when on "Income result" page' do
    before { visit evidence_result_path(id: evidence.id) }

    it 'displays the title of the page' do
      expect(page).to have_content('Income')
    end

    it 'displays a result block' do
      expect(page).to have_xpath('//div[contains(@class,"callout")]/h3[@class="bold"]')
    end

    context 'when the evidence check returns none' do
      let(:outcome) { 'none' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-none")]/h3[@class="bold"]', text: '✗ The applicant must pay the full fee') }
    end

    context 'when the evidence check returns [part]' do
      let(:outcome) { 'part' }
      let(:amount) { 45 }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-part")]/h3[@class="bold"]', text: 'The applicant must pay £45 towards the fee') }
    end

    context 'when the evidence check returns full' do
      let(:outcome) { 'full' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-full")]/h3[@class="bold"]', text: '✓ The applicant doesn’t have to pay the fee') }
    end
  end

  context 'when on "Evidence confirmation" page' do
    before { visit evidence_confirmation_path(id: evidence.id) }

    it { expect(page).to have_content 'Processing complete' }
  end
end
