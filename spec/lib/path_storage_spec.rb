RSpec.describe PathStorage do
  let(:storage_class) { described_class.new(user) }
  let(:storage) { Redis.new }
  let(:user) { build(:user, id: 134) }
  let(:storage_key) { "application-path-134" }
  let(:list_from_storage) { JSON.parse(storage.get(storage_key)) }

  describe '#navigation' do
    let(:path) { '/path/to/page-2' }
    let(:path_value) { list_from_storage.last }

    before { storage.set(storage_key, nil) }

    it 'add to list' do
      storage_class.navigation(path)
      path_value = JSON.parse(storage.get(storage_key)).last
      expect(path_value).to eql(path)
    end

    context 'part payment POST path' do
      let(:path) { '/part_payments/132/return_application' }
      it 'filter some paths' do
        storage_class.navigation(path)
        path_value = JSON.parse(storage.get(storage_key)).last
        expect(path_value).not_to eql(path)
        expect(path_value).to eql('/part_payments/132')
      end
    end


    context 'catch exception' do
      let(:list) { ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3'] }

      before {
        allow(Redis).to receive(:new).and_raise(StandardError)
        allow(Sentry).to receive(:capture_message)
      }

      it 'sent message to Sentry from storage method' do
        storage_class.navigation(path)
        expect(Sentry).to have_received(:capture_message).with('StandardError', extra: { type: "storage", redis_url: "redis://localhost:6379/1" })
      end

      it 'sent message to Sentry from navigation method' do
        storage_class.navigation(path)
        expect(Sentry).to have_received(:capture_message).with("undefined method 'get' for an instance of String", extra: { type: "navigation", current_path: "/path/to/page-2", user_key: "application-path-134" })
      end

      it 'sent message to Sentry from path back method' do
        storage_class.path_back
        expect(Sentry).to have_received(:capture_message).with("undefined method 'get' for an instance of String", extra: { type: "path_back", current_path: nil, user_key: "application-path-134" })
      end

      it 'sent message to Sentry from clear! method' do
        storage_class.clear!
        expect(Sentry).to have_received(:capture_message).with("undefined method 'set' for an instance of String", extra: { type: "clear", user_key: "application-path-134" })
      end

      it 'sent message to Sentry from initialise method' do
        described_class.new(nil)
        expect(Sentry).to have_received(:capture_message).with("undefined method 'id' for nil", extra: { type: "initialize", user_key: nil })
      end

    end

    context 'remove from list' do
      before do
        storage.set(storage_key, list.to_json)
        storage_class.navigation(path)
      end

      context 'standard journey' do
        let(:list) { ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3'] }
        it 'ramove last step' do
          path_value = list_from_storage.last
          expect(path_value).to eql(path)
          expect(list_from_storage).to eq(['/path/to/page-1', '/path/to/page-2'])
        end
      end

      context 'when going to random step' do
        let(:list) { ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3', '/path/to/page-4', '/path/to/page-5'] }
        it 'remove previous steps until current page' do
          expect(path_value).to eql(path)
          expect(list_from_storage).to eq(['/path/to/page-1', '/path/to/page-2'])
        end
      end
    end

    describe 'step back' do
      let(:path_back) { storage_class.path_back }

      before {
        storage.set(storage_key, list.to_json)
      }

      context 'step back 4 steps in' do
        let(:list) { ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3', '/path/to/page-4'] }

        it 'return step previous page' do
          expect(path_back).to eql('/path/to/page-3')
          expect(list_from_storage.size).to eq(4)
        end
      end

      context 'step back 1 steps in' do
        let(:list) { ['/path/to/page-1'] }

        it 'return step previous page' do
          expect(path_back).to eql('')
          expect(list_from_storage.size).to eq(1)
        end
      end

      context 'step back 2 steps in' do
        let(:list) { ['/path/to/page-1', '/path/to/page-2'] }

        it 'return step previous page' do
          expect(path_back).to eql('/path/to/page-1')
          expect(list_from_storage.size).to eq(2)
        end
      end

      context 'step back 3 steps in' do
        let(:list) { ['/path/to/page-1', '/path/to/page-2', '/path/to/page-3'] }

        it 'return step previous page' do
          expect(path_back).to eql('/path/to/page-2')
          expect(list_from_storage.size).to eq(3)
        end
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
