# coding: utf-8
require 'rails_helper'

RSpec.feature 'Part Payments flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_part_remission, user: user }
  let(:part_payment) { create :part_payment, application: application }

  before { login_as user }

  context 'when on the part payment flow initial page' do
    before { visit part_payment_path(id: part_payment.id) }

    headings = ['Waiting for part-payment',
                'Process part-payment',
                'Processing details',
                'Personal details',
                'Application details',
                'Result']

    headings.each do |heading_title|
      it "has a heading titled #{heading_title}" do
        expect(page).to have_content heading_title
      end
    end
  end

  context 'when on accuracy page' do
    before { visit accuracy_part_payment_path(id: part_payment.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Part-payment details'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the part-payment correct?'
    end

    scenario 'it re-renders the page when the page is submitted without anything filled in' do
      click_button 'Next'

      expect(page).to have_content 'Is the part-payment correct?'
    end

    scenario 'confirming the payment is correct redirects to the summary' do
      choose 'part_payment_correct_true'
      click_button 'Next'
      expect(page).to have_content 'Check details'
    end

    scenario 'rejecting the payment redirects to the summary page' do
      choose 'part_payment_correct_false'
      expect(page).to have_content 'Describe the problem with the part-payment'
      click_button 'Next'
      expect(page).to have_content 'Check details'
    end
  end

  context 'when on the summary page' do
    before { visit summary_part_payment_path(id: part_payment.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Check details'
    end

    scenario 'confirming payment directs to confirmation page' do
      click_button 'Complete processing'

      expect(page).to have_content 'Processing complete'
    end

    context 'for correct payment' do
      let(:application) { create :application_part_remission, amount_to_pay: 25, user: user }
      let(:part_payment) { create :part_payment, application: application, correct: true }

      scenario 'result and success message are displayed' do
        expect(page).to have_content 'Part payment✓ Passed'
        expect(page).to have_content 'The applicant has paid £25 towards the fee'
      end
    end

    context 'for incorrect payment ' do
      let(:application) { create :application_part_remission, user: user }
      let(:part_payment) { create :part_payment, application: application, correct: false, incorrect_reason: 'REASON' }

      scenario 'result and failure message are displayed' do
        expect(page).to have_content 'Part payment✗ Failed'
        expect(page).to have_content 'ReasonREASON'
        expect(page).to have_content 'The applicant will need to make a new application'
      end
    end
  end

  context 'when on the confirmation page' do
    before { visit confirmation_part_payment_path(id: part_payment.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Processing complete'
    end

    context 'for a successful payment' do
      let(:part_payment) { create :part_payment, correct: true }

      scenario 'a letter copy is not presented' do
        expect(page).to have_no_content 'We have received your payment however it was not correct'
      end
    end

    context 'for a failed payment' do
      let(:part_payment) { create :part_payment, correct: false }

      scenario 'a letter copy is presented' do
        expect(page).to have_content 'We have received your part-payment however it was not correct'
      end
    end
  end
end
