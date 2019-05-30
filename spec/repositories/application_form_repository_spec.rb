require 'rails_helper'

RSpec.describe ApplicationFormRepository do
  subject(:repository) { described_class.new(application, form_params) }

  let(:application) { build_stubbed :application, detail: detail }
  let(:detail) { build_stubbed :detail }
  let(:form_params) do
    { last_name: 'Name', date_of_birth: '20/01/2980', married: false }
  end
  let(:application_details_form) do
    instance_double('Forms::Application::Detail',
                    errors: errors, discretion_applied: discretion_applied)
  end

  let(:discretion_applied) { nil }
  let(:errors) { {} }
  let(:saved) { true }

  describe '#process details' do
    before do
      allow(Forms::Application::Detail).to receive(:new).with(application.detail).and_return(application_details_form)
      allow(application_details_form).to receive(:update_attributes).with(form_params)
      allow(application_details_form).to receive(:save).and_return saved
    end

    context 'no errors and empty discretion' do
      it "return saving path" do
        repository.process(:detail)
        expect(repository.redirect_url).to eql("/applications/#{application.id}/savings_investments")
      end

      context 'discretion_applied granted' do
        let(:discretion_applied) { true }

        it "return saving path" do
          repository.process(:detail)
          expect(repository.redirect_url).to eql("/applications/#{application.id}/savings_investments")
        end
      end
    end

    context 'no errors and discretion denied' do
      let(:discretion_applied) { false }

      it "return saving path" do
        allow(application).to receive(:update).with(outcome: "none", application_type: 'none')
        repository.process(:detail)
        expect(repository.redirect_url).to eql("/applications/#{application.id}/summary")
      end

      context 'udpate application' do
        let(:application) { instance_spy('Application') }
        it "set the outcome" do
          repository.process(:detail)
          expect(application).to have_received(:update).with(outcome: "none", application_type: 'none')
        end
      end
    end

    context 'errors' do
      let(:errors) { [{ date_fee_paid: 'test' }] }
      let(:saved) { false }

      it "blank saving path" do
        repository.process(:detail)
        expect(repository.redirect_url).to be_nil
      end

      it "set the outcome" do
        repository.process(:detail)
        expect(repository.success?).to be_falsey
      end
    end
  end
end
