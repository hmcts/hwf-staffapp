require 'rails_helper'

RSpec.describe 'layouts/application', type: :view do
  before do
    @dwp_state = 'online'
  end

  describe 'menu' do
    describe 'notifications link' do
      context 'when logged out' do
        before { render }

        it 'is hidden' do
          expect(rendered).not_to have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
        end
      end

      context 'when logged in' do
        before do
          sign_in user
          render
        end

        describe 'as admin' do
          let(:user) { create :admin_user }

          it 'is visible' do
            expect(rendered).to have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as user' do
          let(:user) { create :user }

          it 'is hidden' do
            expect(rendered).not_to have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as manager' do
          let(:user) { create :manager }

          it 'is hidden' do
            expect(rendered).not_to have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as mi' do
          let(:user) { create :mi }

          it 'is hidden' do
            expect(rendered).not_to have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end
      end
    end
  end

  describe 'DWP notification' do
    context 'when the service is online' do
      it 'displays the restored message' do
        @dwp_state = 'online'

        expect(render).to have_content I18n.t('error_messages.dwp_restored')
      end
    end

    context 'when the service is failing or restoring' do
      it 'displays the warning message' do
        @dwp_state = 'warning'

        expect(render).to have_content I18n.t('error_messages.dwp_warning')
      end
    end

    context 'when the service is offline' do
      it 'displays the unavailable message' do
        @dwp_state = 'offline'

        expect(render).to have_content I18n.t('error_messages.dwp_unavailable')
      end
    end
  end
end
