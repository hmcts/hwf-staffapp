require 'rails_helper'

RSpec.describe 'layouts/application' do
  describe 'menu' do
    describe 'notifications link' do
      context 'when logged out' do
        before { render }

        it 'is hidden' do
          expect(rendered).to have_no_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
        end
      end

      context 'when logged in' do
        before do
          sign_in user
          render
        end

        describe 'as admin' do
          let(:user) { create(:admin_user) }

          it 'is visible' do
            expect(rendered).to have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as user' do
          let(:user) { create(:user) }

          it 'is hidden' do
            expect(rendered).to have_no_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as manager' do
          let(:user) { create(:manager) }

          it 'is hidden' do
            expect(rendered).to have_no_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as mi' do
          let(:user) { create(:mi) }

          it 'is hidden' do
            expect(rendered).to have_no_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end
      end
    end
  end

  describe 'DWP notification' do
    context 'when the service is online' do
      it 'displays the restored message' do
        @dwp_state = 'online'

        expect(render).to have_text I18n.t('error_messages.dwp_restored')
      end
    end

    context 'when the service is failing or restoring' do
      it 'displays the warning message' do
        @dwp_state = 'warning'

        expect(render).to have_text I18n.t('error_messages.dwp_warning')
        expect(render).to have_text I18n.t('error_messages.dwp_warning_text')
      end
    end

    context 'when the service is offline' do
      it 'displays the unavailable message' do
        @dwp_state = 'offline'

        expect(render).to have_text I18n.t('error_messages.dwp_unavailable')
        expect(render).to have_text I18n.t('error_messages.dwp_unavailable_text')
      end
    end
  end

  describe 'HMRC notification' do
    context 'when the service is online' do
      before { @hmrc_state = 'online' }

      it 'displays the working message' do
        expect(render).to have_text I18n.t('error_messages.hmrc_restored')
      end

      it 'does not display a problem box' do
        expect(render).to have_no_text I18n.t('error_messages.hmrc_warning_header')
      end
    end

    context 'when the service is failing or restoring' do
      before { @hmrc_state = 'warning' }

      it 'displays the warning message' do
        expect(render).to have_text I18n.t('error_messages.hmrc_warning')
      end

      it 'displays the warning box' do
        expect(render).to have_text I18n.t('error_messages.hmrc_warning_header')
        expect(rendered).to have_text I18n.t('error_messages.hmrc_warning_text')
      end
    end

    context 'when the service is offline' do
      before { @hmrc_state = 'offline' }

      it 'displays the unavailable message' do
        expect(render).to have_text I18n.t('error_messages.hmrc_unavailable')
      end

      it 'displays the problem box' do
        expect(render).to have_text I18n.t('error_block.heading')
        expect(rendered).to have_text I18n.t('error_messages.hmrc_unavailable_text')
      end
    end

    context 'when no state is set' do
      it 'does not render the banner' do
        expect(render).to have_no_css('[class^="hmrc-banner-"]')
      end
    end
  end

end
