require 'rails_helper'

RSpec.describe ReferenceGenerator, type: :service do
  describe '.generate' do
    let(:random_string) { 'ab3c' }
    before do
      allow(SecureRandom).to receive(:hex).and_return(random_string)
    end

    subject { described_class.generate }

    it 'returns a random string with capital leters and numbers' do
      is_expected.to eql('AB3C')
    end
  end
end
