require 'rails_helper'

RSpec.describe Application, type: :model do

  let(:user)  { create :user }
  let(:application) { described_class.create(user_id: user.id) }

  before do
    stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
    {
      birth_date: (Time.zone.today - 18.years).strftime('%Y%m%d'),
      entitlement_check_date: (Time.zone.today - 1.month).strftime('%Y%m%d'),
      id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
      ni_number: 'AB123456A',
      surname: 'TEST'
    }).to_return(status: 200, body: '', headers: {})

    application.date_of_birth = Time.zone.today - 18.years
    application.date_received = Time.zone.today - 1.month
    application.ni_number = 'AB123456A'
  end

  context 'when saved without required fields' do
    it 'does not run a benefit check' do
      expect { application.save } .to_not change { application.benefit_checks.count }
    end
  end

  context 'when the final item required is saved' do
    before { application.last_name = 'TEST' }
    it 'runs a benefit check ' do
      expect { application.save } .to change { application.benefit_checks.count }.by 1
    end

    context 'when other fields are changed' do
      before do
        application.last_name = 'TEST'
        application.save
        application.fee = 300
      end

      it 'does not perform another benefit check' do
        expect { application.save } .to_not change { application.benefit_checks.count }
      end
    end

    context 'when date_fee_paid is updated' do
      before do
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
        {
          birth_date: (Time.zone.today - 18.years).strftime('%Y%m%d'),
          entitlement_check_date: (Time.zone.today - 2.weeks).strftime('%Y%m%d'),
          id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
          ni_number: 'AB123456A',
          surname: 'TEST'
        }).to_return(status: 200, body: '', headers: {})

        application.last_name = 'TEST'
        application.save
        application.date_fee_paid = Time.zone.today - 2.weeks
      end

      it 'runs a benefit check' do
        expect { application.save } .to change { application.benefit_checks.count }.by 1
      end

      it 'sets the new benefit check date' do
        application.save
        expect(application.last_benefit_check.date_to_check).to eq Time.zone.today - 2.weeks
      end
    end

    context 'when a benefit check field is changed' do
      before do
        stub_request(:post, "#{ENV['DWP_API_PROXY']}/api/benefit_checks").with(body:
        {
          birth_date: (Time.zone.today - 18.years).strftime('%Y%m%d'),
          entitlement_check_date: (Time.zone.today - 1.month).strftime('%Y%m%d'),
          id: "#{user.name.gsub(' ', '').downcase.truncate(27)}@#{application.created_at.strftime('%y%m%d%H%M%S')}.#{application.id}",
          ni_number: 'AB123456A',
          surname: 'NEW NAME'
        }).to_return(status: 200, body: '', headers: {})

        application.last_name = 'TEST'
        application.save
        application.last_name = 'New name'
      end

      it 'runs a benefit check' do
        expect { application.save } .to change { application.benefit_checks.count }.by 1
      end
    end
  end
end
