require 'rails_helper'

RSpec.describe Reference, type: :model do

  let(:code) { 'foo' }
  let(:reference) { described_class.new(entity_code: code) }

  describe 'validations' do
    it 'needs to have a secure_random' do
      reference.secure_random = ''
      expect(reference).not_to be_valid
    end

    it 'needs to have reference_hash' do
      reference.reference_hash = ''
      expect(reference).not_to be_valid
    end
  end

  it 'will have secure_random pre-populated' do
    expect(reference.secure_random).not_to be_blank
  end

  it 'responds to entity_code' do
    expect(reference).to respond_to :entity_code
  end

  describe 'reference_hash' do
    it 'contains entity code and 8 char hash separated with a hyphen' do
      expect(reference.reference_hash).to match(/\A#{code.upcase}-[A-Z0-9]{4}-[A-Z0-9]{4}\z/)
    end
  end

  describe 'initialization without entity_code' do
    it 'needs to raise an error' do
      expect {
        described_class.new
      }.to raise_exception(NoMethodError, 'Please provide entity_code when initalising')
    end
  end
end
