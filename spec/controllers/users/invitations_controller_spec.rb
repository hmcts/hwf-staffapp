# coding: utf-8

require 'rails_helper'

RSpec.describe Users::InvitationsController do
  render_views

  let(:office) { create(:office) }
  let(:admin_user) { create(:admin_user, office: office) }
  let(:manager_user) { create(:manager, office: office) }
  let(:user) { build(:user) }
  let(:user_email) { user.email }

  let(:invitation) do
    {
      name: user.name,
      email: user_email,
      office_id: office.id
    }
  end

  let(:manager_invitation) { invitation.merge!(role: 'manager') }
  let(:admin_invitation) { invitation.merge(role: 'admin') }

  let(:invited_user) { User.where(email: user.email).first }
  let(:user_invite_mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

  before {
    request.env["devise.mapping"] = Devise.mappings[:user]
    allow(NotifyMailer).to receive_messages(user_invite: user_invite_mailer)
  }

  context 'Manager user' do
    describe 'POST #create' do

      before { sign_in manager_user }

      describe 'does allow you to invite managers as a manager' do
        before { post :create, params: { user: manager_invitation } }

        it { expect(invited_user['email']).to eq user.email }
        it { expect(invited_user['invited_by_id']).to eq manager_user.id }
        it { expect(assigns(:roles)).to eq(['user', 'manager', 'reader']) }

      end

      context 'when manager tries to invite an admin' do
        it 'raises Pundit error' do
          expect {
            bypass_rescue
            post :create, params: { user: admin_invitation }
          }.to raise_error Pundit::NotAuthorizedError
        end
      end

      context 'when manager tries to invite a deleted user' do
        let(:user_email) { user.email }

        before do
          create(:deleted_user, email: user_email, office: office)
          post :create, params: { user: manager_invitation }
        end

        it 'restores and invites the user' do
          expect(response).to render_template(:new)
        end

        it 'renders a flash warning' do
          expect(flash[:alert]).to include('That user has previously been deleted')
        end

        context 'case insesitive' do
          let(:user_email) { user.email.capitalize }

          it 'renders a flash warning' do
            expect(flash[:alert]).to include('That user has previously been deleted')
          end
        end
      end
    end

    context 'Admin user' do
      describe 'POST #create' do

        before { sign_in admin_user }

        describe 'does allow you to invite managers as an admin' do
          before { post :create, params: { user: manager_invitation } }

          it { expect(invited_user['email']).to eq user.email }
          it { expect(invited_user['invited_by_id']).to eq admin_user.id }
        end

        describe 'does allow admins to invite admins' do
          before { post :create, params: { user: admin_invitation } }

          it { expect(invited_user['email']).to eq user.email }
          it { expect(invited_user['invited_by_id']).to eq admin_user.id }

          it {
            invited_user = User.last
            allow(User).to receive(:invite!).and_return invited_user
            expect(NotifyMailer).to have_received(:user_invite).with(invited_user)
          }
        end
      end
    end
  end
end
