require 'rails_helper'

RSpec.feature 'Application details page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_full_remission, user: user }
  let!(:evidence) { create :evidence_check, application_id: application.id }
  headings = ['Waiting for evidence', 'Process evidence', 'Processing details', 'Personal details', 'Application details', 'Assessment']

  before do
    login_as user
    visit evidence_path(id: evidence.id)
  end

  headings.each do |heading_title|
    it "has a heading titled #{heading_title}" do
      expect(page).to have_content heading_title
    end
  end
end
