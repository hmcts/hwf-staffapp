require 'rails_helper'

RSpec.describe 'layouts/application', type: :view do
  describe 'menu' do
    describe 'notifications link' do
      context 'when logged out' do
        before { render }

        it 'is hidden' do
          expect(rendered).to_not have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
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
            expect(rendered).to_not have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as manager' do
          let(:user) { create :manager }

          it 'is hidden' do
            expect(rendered).to_not have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end

        describe 'as mi' do
          let(:user) { create :mi }

          it 'is hidden' do
            expect(rendered).to_not have_xpath("//a[contains(@href,'#{edit_notifications_path}')]")
          end
        end
      end
    end
  end
end
