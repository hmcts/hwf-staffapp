require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { create :user }

  describe 'when viewed' do

    before(:each) { assign(:user, user) }

    ['admin_user', 'manager'].each do |role|

      let(:elevated) { create role.to_sym }

      context "as a #{role}" do
        it 'renders links to delete and view list' do
          sign_in elevated
          render
          expect(rendered).to have_xpath("//a[@href='#{edit_user_path(user)}']")
          expect(rendered).to have_xpath("//a[@href='#{users_path}']")
          expect(rendered).to have_xpath("//a[@href='#{user_path(user)}' and @data-method='delete']")
        end
      end
    end

    context 'as a standard user' do
      it 'hides links to delete and view list' do
        sign_in user
        render
        expect(rendered).to have_xpath("//a[@href='#{edit_user_path(user)}']")
        expect(rendered).not_to have_xpath("//a[@href='#{user_path(user)}' and @data-method='delete']")
        expect(rendered).not_to have_xpath("//a[@href='#{users_path}']")
      end
    end
  end
end
