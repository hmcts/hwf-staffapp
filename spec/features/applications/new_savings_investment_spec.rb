require 'rails_helper'

RSpec.feature 'savings and investments partner over 61 checkbox', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    Capybara.current_driver = :webkit
  end

  after { Capybara.use_default_driver }

  context 'as a signed in user with default jurisdiction', js: true do
    before do
      login_as user
      visit application_savings_investments_path(application)
    end

    context 'processing a paper form where the applicant has more than £3000 savings' do
      before do
        choose :application_min_threshold_exceeded_true
      end

      context 'and is single and under 61' do
        let(:application) { create :single_applicant_under_61, office: user.office, jurisdiction: user.jurisdiction, saving: create(:saving_blank) }

        scenario 'the amount field is displayed' do
          expect(page).to have_content('How much do they have in savings and investments?')
        end
      end

      context 'and is single and over 61' do
        let(:application) { create :single_applicant_over_61, office: user.office, jurisdiction: user.jurisdiction, saving: create(:saving_blank) }

        scenario 'the max threshold is displayed' do
          expect(page).to have_content('In question 8, how much do they have?')
        end
      end

      context 'and is married and under 61' do
        let(:application) { create :married_applicant_under_61, office: user.office, jurisdiction: user.jurisdiction, saving: create(:saving_blank) }

        scenario 'the partners age question is displayed' do
          expect(page).to have_content("In question 8, is the applicant's partner 61 or over?")
        end

        context 'when the partner is under 61' do
          before { choose :application_over_61_false }

          scenario 'the amount field is displayed' do
            expect(page).to have_content('How much do they have in savings and investments?')
          end
        end

        context 'when the partner is over 61' do
          before { choose :application_over_61_true }

          scenario 'the max threshold is displayed' do
            expect(page).to have_content('In question 8, how much do they have?')
          end
        end
      end

      context 'and is married and over 61' do
        let(:application) { create :married_applicant_over_61, office: user.office, jurisdiction: user.jurisdiction, saving: create(:saving_blank) }

        scenario 'the max threshold is displayed' do
          expect(page).to have_content('In question 8, how much do they have?')
        end
      end
    end
  end
end
