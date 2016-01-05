shared_examples_for 'Pundit denies access to' do |view|
  let(:manager)   { create :manager }
  let(:user)      { create :user }

  describe "GET ##{view}" do

    subject { -> { get view } }

    context 'they are not signed in' do
      before { get view }

      subject { response }

      it { is_expected.to have_http_status(:redirect) }

      it { is_expected.to redirect_to(user_session_path) }
    end

    context 'as a user' do
      before { sign_in user }

      it { is_expected.to raise_error(Pundit::NotAuthorizedError) }
    end

    context 'as a manager' do
      before { sign_in manager }

      it { is_expected.to raise_error(Pundit::NotAuthorizedError) }
    end
  end
end
