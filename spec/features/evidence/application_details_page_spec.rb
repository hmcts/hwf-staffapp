require 'rails_helper'

RSpec.feature 'Application details page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_full_remission, user: user }
  let!(:evidence) { create :evidence_check, application_id: application.id }

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
  end

  context 'when on "Evidence accuracy" page' do
    before { visit evidence_accuracy_path(id: evidence.id) }

    it 'displays the title of the page' do
      expect(page).to have_content 'Evidence'
    end

    it 'displays the form label' do
      expect(page).to have_content 'Is the evidence correct?'
    end
  end
end
