require 'rails_helper'

RSpec.describe 'users/index', type: :view do

  include Devise::TestHelpers

  before { assign(:users, create_list(:user, 2)) }

  describe 'when viewed' do
    context 'as an admin' do
      let(:admin) { create :admin_user }
      before do
        sign_in admin
        render
      end

      it 'renders a link to the delete page' do
        expect(rendered).to have_link('List deleted users')
      end
    end

    context 'as a manager' do
      let(:manager) { create :manager }
      before do
        sign_in manager
        render
      end

      it 'does not render a link to the delete page' do
        expect(rendered).not_to have_link('List deleted users')
      end
    end
  end
end
