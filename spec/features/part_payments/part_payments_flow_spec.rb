# coding: utf-8
require 'rails_helper'

RSpec.feature 'Part Payments flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:user) { create :user, office: office }
  let(:application) { create :application_part_remission, user: user, amount_to_pay: 25, office: office }
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

    describe 'confirming the payment is correct' do
      before do
        choose 'part_payment_correct_true'
        click_button 'Next'
      end

      scenario 'it redirects to the summary page and displays correct details' do
        expect(page).to have_content 'Check details'
        expect(page).to have_content 'Part payment✓ Passed'
        expect(page).to have_content 'The applicant has paid £25 towards the fee'
      end

      describe 'clicking on the Complete processing button' do
        before do
          click_button 'Complete processing'
        end

        scenario 'redirects to the confirmation page with the correct content' do
          expect(page).to have_content 'Processing complete'
          expect(page).to have_no_content 'We have received your payment however it was not correct'
        end
      end
    end

    describe 'rejecting the payment' do
      before do
        choose 'part_payment_correct_false'
        fill_in 'part_payment_incorrect_reason', with: 'REASON'
        click_button 'Next'
      end

      scenario 'it redirects to the summary page and displays correct details' do
        expect(page).to have_content 'Check details'
        expect(page).to have_content 'Part payment✗ Failed'
        expect(page).to have_content 'ReasonREASON'
        expect(page).to have_content 'The applicant will need to make a new application'
      end

      describe 'clicking on the Complete processing button' do
        before do
          click_button 'Complete processing'
        end

        scenario 'redirects to the confirmation page with the correct content' do
          expect(page).to have_content 'Processing complete'
          expect(page).to have_content 'We have received your part-payment towards your fee. However we are unable to accept it because:'
        end
      end

      context 'when on part_payment confirmation" page' do
        let(:outcome) { 'full' }
        before { visit confirmation_part_payment_path(id: part_payment.id) }

        scenario 'the remission register right hand guidance is not shown' do
          expect(page).to have_no_content 'remission register'
        end
      end
    end
  end
end
