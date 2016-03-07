require 'rails_helper'

RSpec.feature 'Prevent managers from downgrading themselves to user role', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:manager) { create :manager }
  let(:other_manager) { create :manager, office_id: manager.office_id }

  before { login_as manager }

  context 'their own edit view' do
    before { visit edit_user_path(manager.id) }

    it 'shows the role' do
      expect(page).to have_text 'Role'
    end

    it "doesn't allow editing of the role" do
      expect(page).not_to have_xpath '//*[@id="user_role_user"]'
    end
  end

  context "some other manager's edit view" do
    before { visit edit_user_path(other_manager.id) }

    it "does allow editing of the role" do
      expect(page).to have_xpath '//*[@id="user_role_user"]'
    end
  end
end
