require 'rails_helper'

RSpec.describe StatusNotificationSchedule do
  let(:start) { Time.zone.local(2026, 11, 11, 9, 0, 0) }

  # Runs one monitoring check at the given minute and returns the email it asked for, or nil.
  def check_at(minute, monitor_state, service: 'hmrc')
    email = nil
    travel_to(start + minute.minutes) do
      described_class.new(service, monitor_state).run { |due_email| email = due_email }
    end
    email
  end

  # Runs a check every five minutes from `from` to `to` and returns { minute => email } for checks that sent one.
  def checks_every_five_minutes(from:, to:, monitor_state:)
    (from..to).step(5).each_with_object({}) do |minute, sent|
      email = check_at(minute, monitor_state)
      sent[minute] = email if email
    end
  end

  describe 'HMRC goes offline (AC1)' do
    it 'sends the down email on the first offline check' do
      expect(check_at(0, 'offline')).to eq(:down)
    end

    it 'counts it as notification 1' do
      check_at(0, 'offline')
      expect(StatusNotification.find_by(service: 'hmrc')).to have_attributes(outage_open: true, sent_count: 1)
    end
  end

  describe 'prolonged outage (AC2 and AC3)' do
    it 'sends emails 1-3 five minutes apart, then one every 30 minutes' do
      sent = checks_every_five_minutes(from: 0, to: 120, monitor_state: 'offline')
      expect(sent).to eq(0 => :down, 5 => :down, 10 => :down, 40 => :down, 70 => :down, 100 => :down)
    end

    it 'sends nothing on an extra check in between' do
      check_at(0, 'offline')
      expect(check_at(2, 'offline')).to be_nil
    end

    it 'allows for the cron running a little early' do
      check_at(0, 'offline')
      expect(check_at(4.9, 'offline')).to eq(:down)
    end
  end

  describe 'HMRC recovers (AC4)' do
    before { checks_every_five_minutes(from: 0, to: 45, monitor_state: 'offline') }

    it 'sends the up email on the first online check' do
      expect(check_at(50, 'online')).to eq(:up)
    end

    it 'resets the cycle' do
      check_at(50, 'online')
      expect(StatusNotification.find_by(service: 'hmrc')).to have_attributes(outage_open: false, sent_count: 0, last_sent_at: nil)
    end

    it 'sends the up email only once' do
      check_at(50, 'online')
      expect(check_at(55, 'online')).to be_nil
    end
  end

  describe 'new outage after recovery (AC5)' do
    it 'starts the five-minute phase again' do
      checks_every_five_minutes(from: 0, to: 45, monitor_state: 'offline')
      check_at(50, 'online')

      sent = checks_every_five_minutes(from: 60, to: 100, monitor_state: 'offline')
      expect(sent).to eq(60 => :down, 65 => :down, 70 => :down, 100 => :down)
    end
  end

  describe 'online with no outage' do
    it 'sends nothing' do
      expect(checks_every_five_minutes(from: 0, to: 30, monitor_state: 'online')).to be_empty
    end
  end

  describe 'amber (warning) plays no part' do
    it 'sends nothing from green' do
      expect(checks_every_five_minutes(from: 0, to: 30, monitor_state: 'warning')).to be_empty
    end

    it 'does not end an outage or send emails while amber' do
      check_at(0, 'offline')
      expect(checks_every_five_minutes(from: 5, to: 60, monitor_state: 'warning')).to be_empty
      expect(StatusNotification.find_by(service: 'hmrc')).to have_attributes(outage_open: true, sent_count: 1)
    end

    it 'carries on the same outage when it goes back to offline' do
      check_at(0, 'offline')
      check_at(5, 'warning')
      expect(check_at(10, 'offline')).to eq(:down)
      expect(StatusNotification.find_by(service: 'hmrc').sent_count).to eq(2)
    end

    it 'sends the up email when it goes from amber to green after an outage' do
      check_at(0, 'offline')
      check_at(5, 'warning')
      expect(check_at(10, 'online')).to eq(:up)
    end
  end

  describe 'when sending fails' do
    it 'does not record the email, so the next check tries again' do
      expect do
        travel_to(start) { described_class.new('hmrc', 'offline').run { raise 'Notify error' } }
      end.to raise_error('Notify error')

      expect(StatusNotification.find_by(service: 'hmrc')).to have_attributes(outage_open: false, sent_count: 0)
      expect(check_at(1, 'offline')).to eq(:down)
    end
  end

  describe 'services are tracked separately' do
    it 'keeps a DWP outage apart from HMRC' do
      check_at(0, 'offline', service: 'dwp')
      expect(check_at(1, 'offline', service: 'hmrc')).to eq(:down)
      expect(check_at(2, 'online', service: 'dwp')).to eq(:up)
    end
  end
end
