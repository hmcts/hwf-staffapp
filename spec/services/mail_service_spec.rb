require 'rails_helper'

RSpec.describe MailService do

  subject(:service) { described_class.new(source_data) }

  describe '#build_public_confirmation' do

    subject(:email) { service.send_public_confirmation }

    describe 'when initialised with nil' do
      let(:source_data) { nil }

      it { is_expected.to be false }
    end

    describe 'when initialised without a OnlineApplication' do
      let(:source_data) { build :feedback }

      it { is_expected.to be false }

    end

    describe 'when initialised with a OnlineApplication without a users email' do
      let(:source_data) { build :online_application }

      it { is_expected.to be false }
    end

    describe 'when initialised with a OnlineApplication with a users email' do
      let(:source_data) { build :online_application, :with_email }

      it { is_expected.to be_a Mail::Message }
    end
  end
end
