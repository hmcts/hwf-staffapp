# coding: utf-8
require 'rails_helper'

RSpec.feature 'Payments flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_part_remission, user: user }
  let(:payment) { create :payment, application: application }

  before { login_as user }

  context 'when on the payment flow initial page' do
    before { visit payment_path(id: payment.id) }

    headings = ['Waiting for payment',
                'Process payment',
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
    before { visit accuracy_payment_path(id: payment.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Payment details'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the payment correct?'
    end

    scenario 'it re-renders the page when the page is submitted without anything filled in' do
      click_button 'Next'

      expect(page).to have_content 'Is the payment correct?'
    end

    scenario 'confirming the payment is correct redirects to the summary' do
      choose 'payment_correct_true'
      click_button 'Next'
      expect(page).to have_content 'Check details'
    end

    scenario 'rejecting the payment redirects to the summary page' do
      choose 'payment_correct_false'
      expect(page).to have_content 'What is incorrect about the payment?'
      click_button 'Next'
      expect(page).to have_content 'Check details'
    end
  end

  context 'when on the summary page' do
    before { visit summary_payment_path(id: payment.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Check details'
    end

    scenario 'confirming payment directs to confirmation page' do
      click_button 'Complete processing'

      expect(page).to have_content 'Processing complete'
    end

    context 'for correct payment' do
      let(:application) { create :application_part_remission, user: user }
      let(:payment) { create :payment, application: application, correct: true }

      scenario 'result and success message are displayed' do
        expect(page).to have_content 'Part payment✓ Passed'
        # It is 10, because it is calculated in the Application model on save
        # Todo this should be changed when the model becomes much lighter
        expect(page).to have_content 'The applicant has paid £10 towards the fee'
      end
    end

    context 'for incorrect payment ' do
      let(:application) { create :application_part_remission, user: user }
      let(:payment) { create :payment, application: application, correct: false, incorrect_reason: 'REASON' }

      scenario 'result and failure message are displayed' do
        expect(page).to have_content 'Part payment✗ Failed'
        expect(page).to have_content 'ReasonREASON'
        expect(page).to have_content 'The applicant will need to make a new application'
      end
    end
  end

  context 'when on the confirmation page' do
    before { visit confirmation_payment_path(id: payment.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Processing complete'
    end

    context 'for a successful payment' do
      let(:payment) { create :payment, correct: true }

      scenario 'a letter copy is not presented' do
        expect(page).to have_no_content 'We have received your payment however it was not correct'
      end
    end

    context 'for a failed payment' do
      let(:payment) { create :payment, correct: false }

      scenario 'a letter copy is presented' do
        expect(page).to have_content 'We have received your payment however it was not correct'
      end
    end
  end
end
