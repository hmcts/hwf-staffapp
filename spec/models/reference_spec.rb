require 'rails_helper'

RSpec.describe Reference, type: :model do

  let(:code) { 'foo' }
  let(:reference) { described_class.new }

  describe 'validations' do
    it 'needs to have a reference' do
      reference.reference = ''
      expect(reference).not_to be_valid
    end
  end
end
