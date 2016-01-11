require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include Devise::TestHelpers

  let(:user) { create :user }

  before do
    sign_in user
  end

  describe 'when action is not authorised' do
    controller do
      def index
        raise Pundit::NotAuthorizedError
      end
    end

    let(:referrer) { nil }

    before do
      request.env['HTTP_REFERER'] = referrer
      get :index
    end

    context 'when the request has a referrer' do
      let(:referrer) { processed_applications_path }

      it 'redirects back to the referrer' do
        expect(request).to redirect_to(referrer)
      end

      it 'sets flash error message' do
        expect(flash[:alert]).to eql('You don’t have permission to do this')
      end
    end

    context 'when the request does not have a referrer' do
      it 'redirects to the root url' do
        expect(request).to redirect_to(root_path)
      end

      it 'sets flash error message' do
        expect(flash[:alert]).to eql('You don’t have permission to do this')
      end
    end
  end
end
