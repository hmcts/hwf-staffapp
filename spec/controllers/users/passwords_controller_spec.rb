require 'rails_helper'

RSpec.describe Users::PasswordsController do
  describe "POST #create" do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context "with valid email" do
      let(:user) { create(:user) }

      before do
        allow(User).to receive(:find_by_email).and_return(user)
        allow(controller).to receive(:send_notification_and_redirect).and_call_original
        allow(controller).to receive(:check_and_update_password_timestamp).and_call_original
      end

      it "calls send_notification_and_redirect" do
        post :create, params: { user: { email: user.email } }
        expect(controller).to have_received(:send_notification_and_redirect).with(no_args)
      end

      it "calls check_and_update_password_timestamp with user" do
        post :create, params: { user: { email: user.email } }
        expect(controller).to have_received(:check_and_update_password_timestamp).with(user)
      end
    end
  end
end
