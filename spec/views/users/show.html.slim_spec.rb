require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { create :user }

  describe 'when viewed' do

    before { assign(:user, user) }

    ['admin_user', 'manager'].each do |role|

      let(:elevated) { create role.to_sym }

      context "as a #{role}" do
        before do
          sign_in elevated
          render
        end

        describe 'renders links to delete and view list' do
          it { expect(rendered).to have_xpath("//a[@href='#{edit_user_path(user)}']") }
          it { expect(rendered).to have_xpath("//a[@href='#{users_path}']") }
          it { expect(rendered).to have_xpath("//a[@href='#{user_path(user)}' and @data-method='delete']") }
        end
      end
    end

    context 'as a standard user' do
      before do
        sign_in user
        render
      end

      describe 'hides links to delete and view list' do
        it { expect(rendered).to have_xpath("//a[@href='#{edit_user_path(user)}']") }
        it { expect(rendered).not_to have_xpath("//a[@href='#{user_path(user)}' and @data-method='delete']") }
        it { expect(rendered).not_to have_xpath("//a[@href='#{users_path}']") }
      end
    end
  end
end
