require 'rails_helper'

RSpec.feature 'Prevent managers from downgrading themselves to user role', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:manager) { create :manager }

  before(:each) do
    login_as manager
    visit edit_user_path(manager.id)
  end

  context 'show view' do
    it 'shows the role' do
      expect(page).to have_text 'Role'
    end

    it "doesn't allow editing of the role" do
      expect(page).to_not have_xpath '//*[@id="user_role_user"]'
    end
  end
end
