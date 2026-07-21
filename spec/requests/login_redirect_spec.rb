require 'rails_helper'

# Guards the CookieOverflow fix: Devise stores the URL an unauthenticated user
# attempted in the session cookie so it can redirect back after sign in. A long
# query string used to overflow the 4KB cookie limit before the login page even
# rendered, and the stored URL was never consumed so it stayed in the cookie for
# the whole logged-in session.
RSpec.describe 'Login redirect' do # rubocop:disable RSpec/DescribeClass
  let(:user) { create(:user) }

  def sign_in_through_form
    post user_session_path, params: { user: { email: user.email, password: 'password1234' } }
  end

  context 'when the attempted URL is a normal size' do
    before { get '/users?sort_by=email' }

    it 'redirects to the sign in page' do
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns the user to the attempted URL after sign in' do
      sign_in_through_form
      expect(response).to redirect_to('/users?sort_by=email')
    end

    it 'removes the stored URL from the session after sign in' do
      sign_in_through_form
      expect(session['user_return_to']).to be_nil
    end
  end

  context 'when the attempted URL is too long for the session cookie' do
    before { get "/users?search=#{'x' * 3000}" }

    it 'redirects to the sign in page without raising CookieOverflow' do
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'does not store the attempted URL' do
      expect(session['user_return_to']).to be_nil
    end

    it 'sends the user to the homepage after sign in' do
      sign_in_through_form
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when a manager signs in for the first time' do
    let(:user) { create(:manager) }

    before { get '/users?sort_by=email' }

    it 'goes to profile setup rather than the attempted URL' do
      sign_in_through_form
      expect(response).to redirect_to(edit_user_path(user))
    end

    it 'still removes the stored URL from the session' do
      sign_in_through_form
      expect(session['user_return_to']).to be_nil
    end
  end
end
