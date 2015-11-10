require 'rails_helper'

describe ResolverService do
  let(:user) { build_stubbed(:user) }

  subject(:resolver) { described_class.new(object, user) }

  describe '#process' do
    Timecop.freeze(Time.zone.now) do
      before { resolver.process }

      context 'when created with an application' do
        let(:object) { create(:application_full_remission) }

        describe 'updates the objects.completed_by value' do
          subject { object.completed_by.name }

          it { is_expected.to eql user.name }
        end

        describe 'sets the completed_at value' do
          subject { object.completed_at }

          it { is_expected.not_to be_nil }
        end
      end
    end
  end
end
