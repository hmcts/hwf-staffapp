require 'rails_helper'

RSpec.describe 'users/deleted', type: :view do

  include Devise::TestHelpers

  let!(:user) { create :user, deleted_at: Time.zone.now }

  describe 'when viewed' do
    context 'as an admin' do
      let(:admin) { create :admin_user }
      before do
        create_list(:user, 2, deleted_at: Time.zone.now)
        assign(:users, User.only_deleted)
        sign_in admin
        render
      end

      it 'renders a link to the user index page' do
        expect(rendered).to have_xpath("//a[@href='#{users_path}']")
      end

      it 'shows users email addresses' do
        expect(rendered).to have_xpath("//td[contains(., '#{user.email}')]")
      end

      it 'has links to restore users' do
        expect(rendered).to have_xpath("//a[@href='#{restore_user_path(user)}' and @data-method='patch']")
      end
    end
  end
end
