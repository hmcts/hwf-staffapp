require 'rails_helper'

RSpec.describe Ahoy::Event, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:visit).optional }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:application).optional }
  end

  describe 'table name' do
    it 'uses ahoy_events table' do
      expect(described_class.table_name).to eq('ahoy_events')
    end
  end

  describe 'creating events' do
    let(:application) { create(:application) }
    let(:user) { create(:user) }

    it 'can be created with application_id' do
      event = described_class.create!(
        name: 'Button Click',
        properties: { button_text: 'Submit' },
        time: Time.current,
        application_id: application.id
      )

      expect(event.application_id).to eq(application.id)
      expect(event.application).to eq(application)
    end

    it 'can be created without application_id' do
      event = described_class.create!(
        name: 'Page View',
        properties: { page: 'home' },
        time: Time.current
      )

      expect(event.application_id).to be_nil
      expect(event.application).to be_nil
    end

    it 'can be created without visit' do
      event = described_class.create!(
        name: 'Button Click',
        properties: {},
        time: Time.current
      )

      expect(event.visit_id).to be_nil
      expect(event.visit).to be_nil
    end

    it 'can be created without user' do
      event = described_class.create!(
        name: 'Button Click',
        properties: {},
        time: Time.current
      )

      expect(event.user_id).to be_nil
      expect(event.user).to be_nil
    end

    it 'stores properties as JSON' do
      properties = {
        button_text: 'Submit',
        page: 'applications_process',
        form_action: '/applications/create'
      }

      event = described_class.create!(
        name: 'Form Submit',
        properties: properties,
        time: Time.current
      )

      expect(event.properties).to eq(properties.stringify_keys)
    end
  end

  describe 'querying events by application' do
    let(:application1) { create(:application) }
    let(:application2) { create(:application) }

    before do
      create(:ahoy_event, name: 'Button Click', application_id: application1.id)
      create(:ahoy_event, name: 'Radio Selection', application_id: application1.id)
      create(:ahoy_event, name: 'Button Click', application_id: application2.id)
      create(:ahoy_event, name: 'Page View', application_id: nil)
    end

    it 'filters events by application_id' do
      events = described_class.where(application_id: application1.id)
      expect(events.count).to eq(2)
      expect(events.pluck(:name)).to match_array(['Button Click', 'Radio Selection'])
    end

    it 'finds events without application_id' do
      events = described_class.where(application_id: nil)
      expect(events.count).to eq(1)
      expect(events.first.name).to eq('Page View')
    end
  end

  describe 'ordering events' do
    let(:application) { create(:application) }

    it 'can order events by time to track application flow' do
      event1 = create(:ahoy_event,
                      name: 'Start Application',
                      application_id: application.id,
                      time: 1.hour.ago)
      event2 = create(:ahoy_event,
                      name: 'Fill Personal Info',
                      application_id: application.id,
                      time: 50.minutes.ago)
      event3 = create(:ahoy_event,
                      name: 'Submit Application',
                      application_id: application.id,
                      time: 40.minutes.ago)

      events = described_class.where(application_id: application.id).order(:time)

      expect(events.pluck(:name)).to eq([
        'Start Application',
        'Fill Personal Info',
        'Submit Application'
      ])
    end
  end
end
