require 'rails_helper'

RSpec.describe OnlineApplicationBenefitsController do
  let(:user) { create(:user) }
  let(:online_application) { build_stubbed(:online_application, benefits: false) }
  let(:jurisdiction) { build_stubbed(:jurisdiction) }
  let(:form) { double }
  let(:id) { online_application.id }
  let(:benefit_check) { nil }
  let(:dwp_down) { false }

  before do
    allow(OnlineApplication).to receive(:find).with(online_application.id.to_s).and_return(online_application)
    allow(online_application).to receive(:last_benefit_check).and_return(benefit_check)
    allow(OnlineApplication).to receive(:find).with('non-existent').and_raise(ActiveRecord::RecordNotFound)
    allow(Forms::OnlineApplication).to receive(:new).with(online_application).and_return(form)
    sign_in user
  end

  describe 'GET #edit' do
    before do
      get :edit, params: { id: id }
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT #update' do
    let(:params) { { benefits_override: benefits_override.to_s, dwp_manual_decision: benefits_override.to_s } }

    before do
      allow(form).to receive(:update).with(params)
      allow(form).to receive(:save).and_return(form_save)
      allow(online_application).to receive_messages(benefits_override: benefits_override, update: true, failed_because_dwp_error?: dwp_down)

      put :update, params: { id: id, online_application: params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      context 'when the paper evidence was provided' do
        let(:benefits_override) { true }

        it 'redirects to the summary page' do
          expect(response).to redirect_to(online_application_path(online_application))
        end
      end

      context 'when the benefit fails on DWP' do
        let(:dwp_down) { true }
        let(:benefits_override) { false }

        # it 'redirects to the home page' do
        #   expect(response).to redirect_to(root_path)
        # end

        # it 'sets the alert flash message' do
        #   expect(flash[:alert]).to eql I18n.t('error_messages.benefit_check.cannot_process_application')
        # end

        it 'redirects to the summary page' do
          expect(response).to redirect_to(online_application_path(online_application))
        end

        context 'benefits_override' do
          let(:benefits_override) { true }

          it 'redirects to the summary page' do
            expect(response).to redirect_to(online_application_path(online_application))
          end
        end
      end

      context 'benefit check was "No" not an error' do
        let(:dwp_down) { false }
        let(:benefits_override) { false }
        it { expect(response).to redirect_to(online_application_path(online_application)) }
      end

    end
  end

end
