RSpec.describe PathStorage do
  let(:storage_class) { described_class.new(user)}
  let(:storage) { Redis.new }
  let(:user) { build(:user, id: 134) }
  let(:storage_key) { "application-path-134" }
  let(:list_from_storage) { JSON.parse(storage.get(storage_key)) }

  describe '#navigation' do
    let(:path) { '/path/to/page-2' }
    before { storage.set(storage_key, nil) }

    it 'add to list' do
      storage_class.navigation(path)
      path_value = JSON.parse(storage.get(storage_key)).last
      expect(path_value).to eql(path)
    end

    context 'remove from list' do
      before do
        list = ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3']
        storage.set(storage_key, list.to_json)
      end

      it do
        storage_class.navigation(path)

        path_value = list_from_storage.last
        expect(path_value).to eql(path)
        expect(list_from_storage).to eq(['/path/to/page-1', '/path/to/page-2'])
      end
    end

    context 'step back' do
      before do
        list = ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3', '/path/to/page-4']
        storage.set(storage_key, list.to_json)
      end

      it 'return step previous page' do
        path_back = storage_class.path_back

        expect(path_back).to eql('/path/to/page-3')
        expect(list_from_storage.size).to eq(4)
      end
    end

    context 'reload same page' do
      before do
        list = ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3', '/path/to/page-4']
        storage.set(storage_key, list.to_json)
      end

      it 'do not remove last page when reload' do
        storage_class.navigation('/path/to/page-4')

        expect(list_from_storage.last).to eql('/path/to/page-4')
        expect(list_from_storage.size).to eq(4)
      end
    end
  end
end
