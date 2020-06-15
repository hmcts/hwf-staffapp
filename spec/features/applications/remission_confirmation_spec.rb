# coding: utf-8

require 'rails_helper'

RSpec.feature 'Confirmation page for remission', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create(:office) }
  let(:user) { create :user, office: office }
  let(:application) { create(:application_part_remission, office: office) }

  def visit_confirmation_page
    visit application_confirmation_path(application_id: application.id)
  end

  context 'as a signed in user', js: true do
    before do
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'
      login_as user
    end

    after { Capybara.use_default_driver }

    context 'who has part remission' do
      let(:part_remission_copy) do
        ['Write to the applicant using the letter on this page.',
         'Store the application form in a secure location until you receive the part payment.',
         'Write the reference number on the top right corner of the paper form']
      end

      context 'after user continues to confirmation page' do
        before { visit_confirmation_page }

        scenario 'they have part remission' do
          expect(application.outcome).to eq 'part'
        end

        scenario 'the part remission copy is show' do
          part_remission_copy.each { |line| expect(page).to have_text line }
        end
      end
    end

    context 'who has full remission' do
      let(:application) { create(:application_full_remission, office: office) }
      let(:full_remission_copy) do
        ['Write the reference number on the top right corner of the paper form',
         'Copy the reference number into the case management system',
         'The applicant’s process can now be issued']
      end

      context 'after user continues to confirmation page' do
        before { visit_confirmation_page }

        scenario 'they have full remission' do
          expect(application.outcome).to eq 'full'
        end

        scenario 'the full remission copy is shown' do
          full_remission_copy.each { |line| expect(page).to have_text line }
        end
      end
    end

    context 'who has no remission' do
      let(:application) { create(:application_no_remission, office: office) }
      let(:no_remission_copy) do
        ['Write the reference number on the top right corner of the paper form',
         'Copy the reference number into the case management system',
         'Write to the applicant and send back all the documents']
      end

      context 'after user continues to confirmation page' do
        before { visit_confirmation_page }

        scenario 'they have no remission' do
          expect(application.outcome).to eq 'none'
        end

        scenario 'the no remission copy is shown' do
          no_remission_copy.each { |line| expect(page).to have_text line }
        end
      end
    end
  end
end
