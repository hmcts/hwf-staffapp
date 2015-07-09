require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  include Devise::TestHelpers

  let(:office)  { create :office, jurisdictions: create_list(:jurisdiction, 3) }
  let(:user)    { create :user, office: office }
  context 'standard user' do

    before(:each) { sign_in user }

    describe 'GET #edit' do
      context 'when trying to edit their own profile' do
        context 'when the users office has jurisdictions' do
          it 'lists the offices jurisdictions' do
            get :edit, id: user.to_param
            expect(assigns(:jurisdictions).count).to eq 3
          end
        end

        context 'when the users office has no jurisdictions' do
          it 'shows text warning' do
            office.jurisdictions.delete_all
            get :edit, id: user.to_param
            expect(assigns(:jurisdictions).count).to eq 0
            expect(response.body).to match I18n.t('error_messages.jurisdictions.none_in_office')
          end
        end
      end
    end
  end
end
