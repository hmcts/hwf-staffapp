require 'rails_helper'

RSpec.describe OnlineApplicationBenefitsController, type: :controller do
  let(:user) { create :user }
  let(:online_application) { build_stubbed(:online_application, benefits: false) }
  let(:jurisdiction) { build_stubbed(:jurisdiction) }
  let(:form) { double }
  let(:id) { online_application.id }

  before do
    allow(OnlineApplication).to receive(:find).with(online_application.id.to_s).and_return(online_application)
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
    let(:params) { { "benefits_override": "#{benefits_override}" } }

    before do
      allow(form).to receive(:update_attributes).with(params)
      allow(form).to receive(:save).and_return(form_save)
      allow(form).to receive(:benefits_override).and_return(benefits_override)
      allow(online_application).to receive(:update).and_return(true)

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

      context 'when the paper evidence was not provided' do
        let(:benefits_override) { false }

        it 'redirects to the home page' do
          expect(response).to redirect_to(root_path)
        end

        it 'sets the alert flash message' do
          expect(flash[:alert]).to eql I18n.t('error_messages.benefit_check.cannot_process_application')
        end
      end
    end
  end

end
