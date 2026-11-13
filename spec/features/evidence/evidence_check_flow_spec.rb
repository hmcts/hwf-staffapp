# coding: utf-8

require 'rails_helper'

RSpec.feature 'Evidence check flow' do
  include Warden::Test::Helpers

  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create(:user, office: office) }
  let(:application) { create(:application_full_remission, user: user, office: office, state: state) }
  let(:outcome) { nil }
  let(:amount) { nil }
  let(:income) { nil }
  let(:state) { 3 }
  let(:evidence) { create(:evidence_check, application: application, outcome: outcome, amount_to_pay: amount, income: income) }

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
        expect(page).to have_text heading_title
      end
    end

    scenario 'when clicked on "Start now", goes to the next page' do
      click_link 'Start now'
      expect(page).to have_text 'Is the evidence ready to process?'
    end
  end

  context 'when on "Evidence show" page for a post UCD application' do
    let(:application) do
      create(:application_full_remission, user: user, office: office, state: state, detail_traits: [:post_ucd])
    end

    before { visit evidence_path(id: evidence.id) }

    context 'when evidence check data is filled in but application is still waiting for evidence' do
      let(:state) { 1 }
      let(:outcome) { 'part' }
      let(:amount) { 100 }
      let(:income) { 2000 }

      it 'still displays the evidence check banner' do
        expect(page).to have_text 'Evidence of income needs to be checked'
      end

      it 'does not display the part payment banner' do
        expect(page).to have_no_text 'The applicant must pay'
      end
    end

    context 'when part payment data is filled in but application is still waiting for part payment' do
      let(:state) { 2 }
      let(:outcome) { 'part' }
      let(:amount) { 100 }
      let(:income) { 2000 }

      before do
        create(:part_payment_part_outcome, application: application)
        visit evidence_path(id: evidence.id)
      end

      it 'still displays the part payment banner' do
        expect(page).to have_text 'The applicant must pay £100 towards the fee'
      end

      it 'does not display the part payment outcome banner' do
        expect(page).to have_no_text 'The applicant has paid'
      end

      it 'does not display the evidence check banner' do
        expect(page).to have_no_text 'Evidence of income needs to be checked'
      end
    end
  end

  context 'when a full remission refund becomes a part remission after the evidence check (post UCD)' do
    # Single applicant, no children: £1500 income gives £40 to pay, so £415 of the £455 fee is refunded.
    let(:application) do
      create(:application_full_remission, user: user, office: office, state: 1, fee: 455, income: 55, refund: true,
                                          applicant_traits: [], dependents: false, children: 0,
                                          detail_traits: [:post_ucd])
    end
    let(:evidence) { create(:evidence_check, application: application) }
    let(:refund_message) { 'The amount to be refunded should be £415' }

    before do
      visit accuracy_evidence_path(id: evidence.id)
      choose 'evidence_correct_true'
      click_button 'Next'
      fill_in 'evidence_income', with: 1500
      click_button 'Next'
    end

    it 'shows the refund on the income result page' do
      expect(page).to have_text(refund_message)
      expect(page).to have_no_text('The applicant must pay')
    end

    it 'shows the same refund on the summary page' do
      click_link_or_button 'Next'
      expect(page).to have_text('Check details')
      expect(page).to have_text(refund_message)
      expect(page).to have_no_text('The applicant must pay')
    end

    it 'shows the same refund on the confirmation page' do
      click_link_or_button 'Next'
      click_link_or_button 'Complete processing'
      expect(page).to have_text('Application complete')
      expect(page).to have_text(refund_message)
      expect(page).to have_no_text('The applicant must pay')
      expect(page).to have_no_text('Eligible for help with fees')
    end
  end

  context 'when on "Evidence accuracy" page' do
    before { visit accuracy_evidence_path(id: evidence.id) }

    context 'when the page is submitted without anything filled in' do
      before { click_button 'Next' }

      it 're-renders the page' do
        expect(page).to have_text 'Is the evidence ready to process?'
      end
    end

    it 'displays the title of the page' do
      expect(page).to have_text 'Evidence'
    end

    it 'displays the form label' do
      expect(page).to have_text 'Is the evidence ready to process?'
    end

    scenario 'confirming the evidence is correct redirects to the income page' do
      choose 'evidence_correct_true'
      click_button 'Next'
      expect(page).to have_text 'Total monthly income from evidence'
    end

    scenario 'rejecting the evidence redirects to the summary page' do
      choose 'evidence_correct_false'
      click_button 'Next'

      expect(page).to have_text 'What is the reason for rejecting the evidence?'
      check 'Requested sources not provided'
      check 'Wrong type provided'
      click_button 'Next'

      expect(page).to have_text 'Check details'
      expect(page).to have_text 'Requested sources not provided'
      expect(page).to have_text 'Wrong type provided'
    end
  end

  context 'when on "Income" page' do
    before { visit income_evidence_path(id: evidence.id) }

    it 'fill in the income form takes me to the next page' do
      expect(page).to have_text 'Total monthly income from evidence'
      fill_in 'evidence_income', with: 500
      click_button 'Next'
    end
  end

  context 'when on "Income result" page' do
    before { visit result_evidence_path(id: evidence.id) }

    it 'displays the title of the page' do
      expect(page).to have_text('Income')
    end

    it 'displays a result block' do
      expect(page).to have_xpath('//div[contains(@class,"callout")]/h2[@class="govuk-heading-l"]')
    end

    context 'when the evidence check returns none' do
      let(:outcome) { 'none' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-none")]/h2[@class="govuk-heading-l"]', text: '✗   Not eligible for help with fees') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_text('Check details')
      end
    end

    context 'when the evidence check returns [part]' do
      let(:outcome) { 'part' }
      let(:amount) { 45.4 }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-part")]/h2[@class="govuk-heading-l"]', text: 'The applicant must pay £45.4 towards the fee') }

      it 'clicking the Next button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_text('Check details')
      end
    end

    context 'when the evidence check returns full' do
      let(:outcome) { 'full' }

      it { expect(page).to have_xpath('//div[contains(@class,"callout-full")]/h2[@class="govuk-heading-l"]', text: 'Eligible for help with fees') }

      it 'clicking the Complete processing button redirects to the summary page' do
        click_link_or_button 'Next'
        expect(page).to have_text('Check details')
      end
    end
  end

  context 'when on "summary" page' do
    before { visit summary_evidence_path(id: evidence.id) }

    context 'for an unsuccessful outcome' do
      let(:evidence) { create(:evidence_check_incorrect, application: application) }
      let(:expected_fields) do
        [
          { title: 'Ready to process', value: 'No', url: accuracy_evidence_path(evidence) },
          { title: 'The problem', value: evidence.incorrect_reason, url: evidence_accuracy_failed_reason_path(evidence) },
          { title: 'Reasons', value: 'Unreadable or illegible, Cannot identify applicant', url: evidence_accuracy_incorrect_reason_path(evidence) }
        ]
      end

      # rubocop:disable RSpec/NoExpectationExample
      it 'renders correct outcome' do
        page_expectation('Not eligible for help with fees', expected_fields)
      end
      # rubocop:enable RSpec/NoExpectationExample

      it 'clicking the Complete processing button redirects to the confirmation page' do
        click_link_or_button 'Complete processing'
        expect(page).to have_text('Application complete')
      end
    end

    context 'for a part remission outcome' do
      let(:evidence) { create(:evidence_check_part_outcome, application: application, amount_to_pay: 43.33) }
      let(:expected_fields) do
        [
          { title: 'Ready to process', value: 'Yes', url: accuracy_evidence_path(evidence) },
          { title: 'Income', value: "£#{evidence.income}", url: income_evidence_path(evidence) }
        ]
      end

      # rubocop:disable RSpec/NoExpectationExample
      it 'renders correct outcome' do
        page_expectation("The applicant must pay £43.33 towards the fee", expected_fields)
      end
      # rubocop:enable RSpec/NoExpectationExample

      context 'clicking the Complete processing button' do
        before { click_link_or_button 'Complete processing' }

        it 'creates a payment record' do
          expect(evidence.application.part_payment).to be_a(PartPayment)
        end

        it 'redirects to the confirmation page' do
          expect(page).to have_text('Application complete')
        end
      end
    end

    context 'for a part remission outcome on a post UCD application' do
      let(:application) do
        create(:application_full_remission, user: user, office: office, state: 1, fee: 300, refund: true,
                                            detail_traits: [:post_ucd])
      end
      let(:evidence) { create(:evidence_check_part_outcome, application: application, amount_to_pay: 43.33) }

      it 'shows the amount to be refunded for a refund' do
        expect(page).to have_text('The amount to be refunded should be £256.67')
        expect(page).to have_no_text('The applicant must pay')
      end

      context 'when it is not a refund' do
        let(:application) do
          create(:application_full_remission, user: user, office: office, state: 1, fee: 300, refund: false,
                                              detail_traits: [:post_ucd])
        end

        it 'shows the amount the applicant must pay' do
          expect(page).to have_text('The applicant must pay £43.33 towards the fee')
        end
      end
    end

    context 'for a full remission outcome' do
      let(:evidence) { create(:evidence_check_full_outcome, application: application) }
      let(:expected_fields) do
        [
          { title: 'Ready to process', value: 'Yes', url: accuracy_evidence_path(evidence) },
          { title: 'Income', value: "£#{evidence.income}", url: income_evidence_path(evidence) }
        ]

      end

      # rubocop:disable RSpec/NoExpectationExample
      it 'renders correct outcome' do
        page_expectation('Eligible for help with fees', expected_fields)
      end
      # rubocop:enable RSpec/NoExpectationExample

      it 'clicking the Next button redirects to the confirmation page' do
        click_link_or_button 'Complete processing'
        expect(page).to have_text('Application complete')
      end
    end

    # rubocop:disable Metrics/AbcSize
    def page_expectation(outcome, fields = [])
      expect(page).to have_text(outcome)
      fields.each do |field|
        expect(page).to have_text("#{field[:title]}#{field[:value]}")
        expect(page).to have_link("Change#{field[:title]}", href: field[:url])
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  context 'when on "Evidence confirmation" page' do
    before {
      create(:part_payment, application: evidence.application)
      visit confirmation_evidence_path(id: evidence.id)
    }
    let(:outcome) { 'full' }
    it { expect(page).to have_text 'Eligible for help with fees' }

    context 'when the reference_date is passed' do
      let(:outcome) { 'full' }
      before do
        travel_to(Date.new(2016, 8, 1)) {
          visit confirmation_evidence_path(id: evidence.id)
        }
      end

      scenario 'the remission register right hand guidance is not shown' do
        expect(page).to have_no_text 'remission register'
      end
    end

    context 'when the remission is' do
      context 'full' do
        let(:outcome) { 'full' }

        it { expect(page).to have_no_text(/(not\ correct\|part-fee)/) }
      end

      context 'part' do
        let(:outcome) { 'part' }
        let(:amount) { 300 }
        let(:pay_by_date) { application.part_payment.expires_at.strftime('%-d %B %Y') }
        let(:state) { 2 }

        it { expect(page).to have_text "You’re eligible to get some money taken off the full fee of £410." }

        it { expect(page).to have_text "You need to pay £300 towards the fee by #{pay_by_date}." }

        it { expect(page).to have_text(evidence.application.applicant.full_name) }

        it { expect(page).to have_text(user.name) }

        it { expect(page).to have_text(amount) }
      end

      context 'rejected' do
        let(:outcome) { 'none' }
        let(:income) { 5000 }
        let(:amount) { application.detail.fee.to_i }
        let(:paid_by) { evidence.expires_at.strftime(Date::DATE_FORMATS[:gov_uk_long]) }
        let(:applicant_letter_text) { 'This is because you have more than the maximum amount of income allowed.' }
        let(:representation_letter_text) do
          'This is because the applicant has more than the maximum amount of income allowed.'
        end
        let(:income_labels) { '(income total|total monthly income|average income for the last 3 months)' }
        let(:applicant_income_line) { /Your #{income_labels}: £5,000/ }
        let(:representation_income_line) { /The applicant's #{income_labels}: £5,000/ }

        context 'signed by the applicant, original income above zero' do
          it { expect(page).to have_text applicant_letter_text }

          it { expect(page).to have_text "Your reference: #{application.reference}" }

          it { expect(page).to have_text(evidence.application.applicant.full_name) }

          it { expect(page).to have_text(user.name) }

          it { expect(page).to have_text "You need to pay the full fee amount of £#{amount} by #{paid_by}." }

          it { expect(page).to have_text '£5,000' }

          it { expect(page).to have_no_text 'Maximum amount of income allowed: £5,490' }

          it { expect(page).to have_text applicant_income_line }
        end

        context 'signed by the applicant, original income zero' do
          let(:application) do
            create(:application_full_remission, user: user, office: office, state: state, income: 0)
          end

          it { expect(page).to have_text applicant_letter_text }

          it { expect(page).to have_text '£5,000' }
        end

        context 'signed by a legal representative, original income above zero' do
          let(:application) do
            create(:application_full_remission, user: user, office: office, state: state,
                                                detail_traits: [:legal_representative]).tap do |app|
              create(:representative, application: app)
            end
          end
          let(:representative) { application.representative }

          it { expect(page).to have_text representation_letter_text }

          it { expect(page).to have_text "Dear #{representative.first_name} #{representative.last_name} regarding" }

          it { expect(page).to have_text "The full fee amount of £#{amount} needs to be paid by #{paid_by}." }

          it { expect(page).to have_text representation_income_line }

          it { expect(page).to have_no_text applicant_income_line }
        end

        context 'signed by a litigation friend, original income zero' do
          let(:application) do
            create(:application_full_remission, user: user, office: office, state: state, income: 0,
                                                detail_traits: [:litigation_friend])
          end

          it { expect(page).to have_text representation_letter_text }

          it { expect(page).to have_text representation_income_line }
        end
      end
    end
  end
end
