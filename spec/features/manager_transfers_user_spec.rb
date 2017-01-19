require 'rails_helper'

RSpec.feature 'Manager transfers user', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  context 'Manager' do
    let(:manager) { create :manager, office: office }

    let(:office) { create :office }
    let(:manager) { create :manager, office: office }
    let(:user) { create :user, office: office }

    let(:another_office) { create :office }
    let(:another_manager) { create :manager, office: another_office }

    before { another_manager }

    scenario 'transfers user from his office to another' do
      login_as(manager)
      visit edit_user_path(user.id)

      select(another_office.name, from: 'user_office_id')
      click_button 'Save changes'

      alert = page.find('.alert-box')
      expect(alert).to have_content("#{user.name} moved to #{another_office.name}")
      expect(alert).to have_link(another_manager.name, href: "mailto:#{another_manager.email}")
    end
  end
end
