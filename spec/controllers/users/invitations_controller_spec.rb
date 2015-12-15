# coding: utf-8
require 'rails_helper'

RSpec.describe Users::InvitationsController, type: :controller do

  include Devise::TestHelpers

  let(:manager_user) { create :manager }
  let(:user) { build :user }

  context 'Manager user' do
    describe 'POST #create' do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in manager_user
      end

      let(:invitation) do
        {
          name: user.name,
          email: user.email,
          role: 'manager',
          office_id: '1'
        }
      end

      let(:admin_invitation) do
        {
          name: user.name,
          email: user.email,
          role: 'admin',
          office_id: '1'
        }
      end

      let(:invited_user) { User.where(email: user.email).first }

      it 'does allow you to invite managers as a manager' do
        post :create, user: invitation

        expect(invited_user['email']).to eq user.email
        expect(invited_user['invited_by_id']).to eq manager_user.id
      end

      it 'does not allow you to invite admins as a manager' do
        expect {
          post :create, user: admin_invitation
        }.to raise_error
      end

    end
  end
end
