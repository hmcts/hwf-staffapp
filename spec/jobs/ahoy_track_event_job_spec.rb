require 'rails_helper'

RSpec.describe AhoyTrackEventJob, type: :job do
  describe '#perform' do
    let(:user) { create(:user) }
    let(:application) { create(:application) }
    let(:event_name) { 'Button Click' }
    let(:properties) do
      {
        'button_text' => 'Submit',
        'application_id' => application.id.to_s,
        'page' => 'applications_process'
      }
    end
    let(:event_data) do
      {
        name: event_name,
        properties: properties,
        time: Time.current,
        visit_id: nil
      }
    end
    let(:job_data) do
      {
        event: event_data,
        user: user
      }
    end

    it 'creates an Ahoy::Event with correct attributes' do
      expect {
        described_class.new.perform(job_data)
      }.to change(Ahoy::Event, :count).by(1)

      event = Ahoy::Event.last
      expect(event.name).to eq(event_name)
      expect(event.properties).to eq(properties)
      expect(event.user).to eq(user)
      expect(event.application_id).to eq(application.id)
    end

    it 'extracts application_id from properties with string key' do
      described_class.new.perform(job_data)
      event = Ahoy::Event.last
      expect(event.application_id).to eq(application.id)
    end

    it 'extracts application_id from properties with symbol key' do
      event_data[:properties] = { application_id: application.id.to_s }
      described_class.new.perform(job_data)
      event = Ahoy::Event.last
      expect(event.application_id).to eq(application.id)
    end

    it 'handles missing application_id gracefully' do
      event_data[:properties] = { 'button_text' => 'Submit' }

      expect {
        described_class.new.perform(job_data)
      }.to change(Ahoy::Event, :count).by(1)

      event = Ahoy::Event.last
      expect(event.application_id).to be_nil
    end

    it 'handles nil properties gracefully' do
      event_data[:properties] = nil

      expect {
        described_class.new.perform(job_data)
      }.to change(Ahoy::Event, :count).by(1)

      event = Ahoy::Event.last
      expect(event.application_id).to be_nil
    end

    it 'logs the event tracking' do
      allow(Rails.logger).to receive(:info)

      described_class.new.perform(job_data)

      expect(Rails.logger).to have_received(:info)
        .with("Ahoy event tracked: #{event_name} for application #{application.id}")
    end

    it 'sets the correct timestamp' do
      freeze_time do
        described_class.new.perform(job_data)
        event = Ahoy::Event.last
        expect(event.time).to be_within(1.second).of(Time.current)
      end
    end

    context 'when user is nil' do
      let(:job_data) do
        {
          event: event_data,
          user: nil
        }
      end

      it 'creates event without user' do
        expect {
          described_class.new.perform(job_data)
        }.to change(Ahoy::Event, :count).by(1)

        event = Ahoy::Event.last
        expect(event.user).to be_nil
      end
    end
  end
end
