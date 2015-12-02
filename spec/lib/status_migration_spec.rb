require 'rails_helper'

RSpec.describe StatusMigration do

  subject(:migration) { described_class.new }

  let!(:application1) do
    create(:application, :uncompleted)
  end

  let!(:application2) do
    create(:application_full_remission).tap do |a|
      create(:evidence_check, application: a)
    end
  end

  let!(:application3) do
    create(:application_full_remission).tap do |a|
      create(:evidence_check, :completed, application: a)
    end
  end

  let!(:application4) do
    create(:application_part_remission).tap do |a|
      create(:part_payment, application: a)
    end
  end

  let!(:application5) do
    create(:application_part_remission).tap do |a|
      create(:part_payment, :completed, application: a)
    end
  end

  let!(:application6) do
    create(:application_part_remission).tap do |a|
      create(:evidence_check, :completed, application: a)
      create(:part_payment, application: a)
    end
  end

  let!(:application7) do
    create(:application_part_remission).tap do |a|
      create(:evidence_check, :completed, application: a)
      create(:part_payment, :completed, application: a)
    end
  end

  let!(:application8) do
    create(:application_full_remission)
  end

  describe '#run!' do
    before do
      migration.run!
    end

    # I'm purposely using only 1 it block with lots assertions to make sure that
    # the states are set correctly on the whole database table, which would not
    # be easy to prove in isolation
    it 'sets correct states for each application type' do
      # unprocessed application -> created
      expect(application1.reload.state).to eql('created')

      # processed application with uncompleted evidence check -> evidence_check
      expect(application2.reload.state).to eql('evidence_check')

      # processed application with completed evidence check -> processed
      expect(application3.reload.state).to eql('processed')

      # processed application with uncompleted part payment -> part_payment
      expect(application4.reload.state).to eql('part_payment')

      # processed application with completed part payment -> processed
      expect(application5.reload.state).to eql('processed')

      # processed application with completed evidence check and uncompleted part payment -> part_payment
      expect(application6.reload.state).to eql('part_payment')

      # processed application with completed evidence check and completed part payment -> processed
      expect(application7.reload.state).to eql('processed')

      # processed application without evidence check or part payment -> processed
      expect(application8.reload.state).to eql('processed')
    end
  end
end
