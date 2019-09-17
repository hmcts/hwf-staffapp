shared_examples 'a user regardless of role' do

  describe 'GET #show' do
    it 'sees a change password link' do
      get :show, params: { id: controller.current_user.to_param }
      expect(response.body).to have_xpath("//a[@href='#{user_registration_path}']")
    end
  end

  describe 'GET #edit' do

    let(:office)  { create :office, jurisdictions: create_list(:jurisdiction, 3) }
    let(:user)    { create :user, office: office }

    before { sign_in user }

    context 'for their own profile' do
      context 'and the users office has jurisdictions' do
        it 'it lists them' do
          get :edit, params: { id: user.to_param }
          expect(assigns(:jurisdictions).count).to eq 3
        end
      end

      context 'and the users office has no jurisdictions' do
        describe 'it shows a text warning' do
          before do
            office.jurisdictions.delete_all
            get :edit, params: { id: user.to_param }
          end

          it { expect(assigns(:jurisdictions).count).to eq 0 }
          it { expect(response.body).to match I18n.t('error_messages.jurisdictions.none_in_office') }
        end
      end
    end
  end
end
