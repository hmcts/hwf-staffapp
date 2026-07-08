require 'rails_helper'

RSpec.describe ReferenceGenerator, type: :service do
  subject(:generator) { described_class.new(application) }

  let(:application) { create(:application, reference: nil) }
  # Letters A-Z minus I, O, S and digits minus 0, 1, 2, 5.
  let(:safe_suffix) { /\A[A-HJ-NP-RT-Z346789]{6}\z/ }

  describe '#attributes' do
    subject(:reference) do
      travel_to(Time.zone.local(2026, 6, 30)) { generator.attributes[:reference] }
    end

    it 'is prefixed with PA and the two-digit year' do
      expect(reference).to start_with('PA26-')
    end

    it 'keeps the PA<yy>-XXXXXX shape and 11-character length' do
      expect(reference).to match(/\APA\d{2}-[A-HJ-NP-RT-Z346789]{6}\z/)
      expect(reference.length).to eq(11)
    end

    it 'generates a suffix with no confusable characters' do
      suffix = reference.split('-').last
      expect(suffix).to match(safe_suffix)
      expect(suffix).not_to match(/[IOS0125]/)
    end
  end

  describe 'uniqueness' do
    # rubocop:disable RSpec/SubjectStub
    it 'regenerates when the first candidate already exists' do
      travel_to(Time.zone.local(2026, 6, 30)) do
        create(:application, :processed_state, reference: 'PA26-AAAAAA')
        allow(generator).to receive(:random_suffix).and_return('AAAAAA', 'BBBBBB')

        expect(generator.attributes[:reference]).to eq('PA26-BBBBBB')
      end
    end
    # rubocop:enable RSpec/SubjectStub

    it 'avoids a reference already used by a purged application' do
      travel_to(Time.zone.local(2026, 6, 30)) do
        purged = create(:application, :processed_state, reference: 'PA26-CCCCCC')
        purged.update(purged: true, purged_at: Time.zone.now) # acts_as_paranoid soft-delete

        # rubocop:disable RSpec/SubjectStub
        allow(generator).to receive(:random_suffix).and_return('CCCCCC', 'DDDDDD')
        # rubocop:enable RSpec/SubjectStub

        expect(generator.attributes[:reference]).to eq('PA26-DDDDDD')
      end
    end

    it 'avoids a reference already used by a state-deleted application' do
      travel_to(Time.zone.local(2026, 6, 30)) do
        create(:application, :deleted_state, reference: 'PA26-EEEEEE')

        # rubocop:disable RSpec/SubjectStub
        allow(generator).to receive(:random_suffix).and_return('EEEEEE', 'FFFFFF')
        # rubocop:enable RSpec/SubjectStub

        expect(generator.attributes[:reference]).to eq('PA26-FFFFFF')
      end
    end

    it 'checks uniqueness with an indexed lookup, not by scanning every reference' do
      allow(Application).to receive(:unscoped).and_call_original
      allow(Application).to receive(:pluck).and_call_original

      travel_to(Time.zone.local(2026, 6, 30)) { generator.attributes }

      expect(Application).to have_received(:unscoped).at_least(:once)
      expect(Application).not_to have_received(:pluck)
    end
  end

  describe '#random_suffix' do
    it 'only ever emits safe characters across many draws' do
      1000.times do
        expect(generator.send(:random_suffix)).to match(safe_suffix)
      end
    end
  end
end
