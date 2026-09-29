RSpec.describe FakeRedis do
  subject(:redis) { described_class.new }

  describe '#set and #get' do
    it 'returns nil for an unknown key' do
      expect(redis.get('missing')).to be_nil
    end

    it 'stores and returns a string value' do
      redis.set('key', '["/path"]')
      expect(redis.get('key')).to eq('["/path"]')
    end

    it 'stores values as strings like Redis does' do
      redis.set('key', nil)
      expect(redis.get('key')).to eq('')
    end

    it 'returns OK from set' do
      expect(redis.set('key', 'value')).to eq('OK')
    end

    it 'keeps data separate between instances' do
      redis.set('key', 'value')
      expect(described_class.new.get('key')).to be_nil
    end
  end

  describe '#del' do
    it 'removes the key and returns the number of removed keys' do
      redis.set('key', 'value')
      expect(redis.del('key')).to eq(1)
      expect(redis.get('key')).to be_nil
    end

    it 'returns 0 for an unknown key' do
      expect(redis.del('missing')).to eq(0)
    end
  end
end
