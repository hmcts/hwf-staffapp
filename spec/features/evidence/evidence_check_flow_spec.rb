# coding: utf-8

require 'rails_helper'

RSpec.feature 'Evidence check flow', type: :feature do
  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:application) { create :application_full_remission, user: user, office: office }
  let(:outcome) { nil }
  let(:amount) { nil }
  let(:income) { nil }
  let(:evidence) { create :evidence_check, application: application, outcome: outcome, amount_to_pay: amount, income: income }

  before { login_as user }

  context 'when on "Evidence show" page' do
    before { visit evidence_path(id: evidence.id) }
    headings = ['Waiting for evidence',
                'Process evidence',
                'Processing summary',
                'Personal details',
                'Application details',
                'Result']

    headings.each do |heading_title|
      it "has a heading titled #{heading_title}" do
        expect(page).to have_content heading_title
      end
    end

    scenario 'when clicked on "Start now", goes to the next page' do
      click_link 'Start now'
      expect(page).to have_content 'Is the evidence ready to process?'
    end
  end

  context 'when on "Evidence accuracy" page' do
    before { visit accuracy_evidence_path(id: evidence.id) }

    context 'when the page is submitted without anything filled in' do
      before { click_button 'Next' }

      it 're-renders the page' do
        expect(page).to have_content 'Is the evidence ready to process?'
      end
    end

    it 'displays the title of the page' do
      expect(page).to have_content 'Evidence'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the evidence ready to process?'
    end

    scenario 'confirming the evidence is correct redirects to the income page' do
      choose 'evidence_correct_true'
      click_button 'Next'
      expect(page).to have_content 'Total monthly income from evidence'
    end

    scenario 'rejecting the evidence redirects to the summary page' do
      choose 'evidence_correct_false'
      click_button 'Next'

      expect(page).to have_content 'What is the reason for rejecting the evidence?'
      check 'Requested sources not provided'
      check 'Wrong type provided'
      click_button 'Next'

      expect(page).to have_content 'Check details'
      expect(page).to have_content 'Requested sources not provided'
      expect(page).to have_content 'Wrong type provided'
    end
  end

  context 'when on "Income" page' do
    before { visit income_evidence_path(id: evidence.id) }

    it 'fill in the income form takes me to the next page' do
      expect(page).to have_content 'Total monthly income from evidence'
      fill_in 'evidence_income', with: 500
      click_button 'Next'
    end
  end

  context 'when on "Income result" page' do
    before { visit result_evidence_path(id: evidence.id) }

    it 'displays the title of the page' do
      expect(page).to have_content('Income')
    end

    it 'displays a result block' do
      expect(page).to have_xpath('//div[contains(@class,"callout")]/h2[@class="govuk-heading-l"]')
    end

    context 'when the evidence check returns none' do
      let(:outcome) { 'none' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-none")]/h2[@class="govuk-heading-l"]', text: '✗ Not eligible for help with fees') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_content('Check details')
      end
    end

    context 'when the evidence check returns [part]' do
      let(:outcome) { 'part' }
      let(:amount) { 45.4 }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-part")]/h2[@class="govuk-heading-l"]', text: 'The applicant must pay £45.4 towards the fee') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_content('Check details')
      end
    end

    context 'when the evidence check returns full' do
      let(:outcome) { 'full' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-full")]/h2[@class="govuk-heading-l"]', text: 'Eligible for help with fees') }

      it 'clicking the Complete processing button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_content('Check details')
      end
    end
  end

  context 'when on "summary" page' do
    before { visit summary_evidence_path(id: evidence.id) }

    context 'for an unsuccessful outcome' do
      let(:evidence) { create :evidence_check_incorrect, application: application }
      let(:expected_fields) do
        [
          { title: 'Ready to process', value: 'No', url: accuracy_evidence_path(evidence) },
          { title: 'The problem', value: evidence.incorrect_reason, url: evidence_accuracy_failed_reason_path(evidence) },
          { title: 'Reasons', value: 'Unreadable or illegible, Cannot identify applicant', url: evidence_accuracy_incorrect_reason_path(evidence) }
        ]
      end

      it 'renders correct outcome' do
        page_expectation('Not eligible for help with fees', expected_fields)
      end

      it 'clicking the Complete processing button redirects to the confirmation page' do
        click_link_or_button 'Complete processing'
        expect(page).to have_content('Processing complete')
      end
    end

    context 'for a part remission outcome' do
      let(:evidence) { create :evidence_check_part_outcome, application: application, amount_to_pay: 43.33 }
      let(:expected_fields) do
        [
          { title: 'Ready to process', value: 'Yes', url: accuracy_evidence_path(evidence) },
          { title: 'Income', value: "£#{evidence.income}", url: income_evidence_path(evidence) }
        ]
      end

      it 'renders correct outcome' do
        page_expectation("The applicant must pay £43.33 towards the fee", expected_fields)
      end

      context 'clicking the Complete processing button' do
        before { click_link_or_button 'Complete processing' }

        it 'creates a payment record' do
          expect(evidence.application.part_payment).to be_a(PartPayment)
        end

        it 'redirects to the confirmation page' do
          expect(page).to have_content('Processing complete')
        end
      end
    end

    context 'for a full remission outcome' do
      let(:evidence) { create :evidence_check_full_outcome, application: application }
      let(:expected_fields) do
        [
          { title: 'Ready to process', value: 'Yes', url: accuracy_evidence_path(evidence) },
          { title: 'Income', value: "£#{evidence.income}", url: income_evidence_path(evidence) }
        ]

      end

      it 'renders correct outcome' do
        page_expectation('Eligible for help with fees', expected_fields)
      end

      it 'clicking the Next button redirects to the confirmation page' do
        click_link_or_button 'Complete processing'
        expect(page).to have_content('Processing complete')
      end
    end

    # rubocop:disable Metrics/AbcSize
    def page_expectation(outcome, fields = [])
      expect(page).to have_content(outcome)
      fields.each do |field|
        expect(page).to have_content("#{field[:title]}#{field[:value]}")
        expect(page).to have_link("Change#{field[:title]}", href: field[:url])
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  context 'when on "Evidence confirmation" page' do
    before { visit confirmation_evidence_path(id: evidence.id) }

    it { expect(page).to have_content 'Processing complete' }

    context 'when the reference_date is passed' do
      let(:outcome) { 'full' }
      before do
        Timecop.freeze(Date.new(2016, 8, 1)) {
          visit confirmation_evidence_path(id: evidence.id)
        }
      end

      scenario 'the remission register right hand guidance is not shown' do
        expect(page).to have_no_content 'remission register'
      end
    end

    context 'when the remission is' do
      context 'full' do
        let(:outcome) { 'full' }

        it { expect(page).to have_no_content(/(not\ correct\|part-fee)/) }
      end

      context 'part' do
        let(:outcome) { 'part' }

        it { expect(page).to have_content 'You are eligible for some money off' }

        it { expect(page).to have_content(evidence.application.applicant.full_name) }

        it { expect(page).to have_content(user.name) }

        it { expect(page).to have_content(evidence.amount_to_pay) }

        it { expect(page).to have_content(evidence.expires_at.strftime('%-d %B %Y')) }
      end

      context 'rejected' do
        let(:outcome) { 'none' }
        let(:income) { 2000 }

        it { expect(page).to have_content ' There’s a problem with the documents you sent' }

        it { expect(page).to have_content(evidence.application.applicant.full_name) }

        it { expect(page).to have_content(user.name) }

        it { expect(page).to have_content(evidence.amount_to_pay) }

        it { expect(page).not_to have_content 'Maximum amount of income allowed: £5,490' }

      end
    end
  end
end
