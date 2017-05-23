require 'rails_helper'

RSpec.describe Notification do
  let(:first_notification) { build(:notification) }

  context 'when notification does not exists' do
    describe 'create first notification' do
      it 'can be created' do
        expect(first_notification.save).to be true
      end
    end
  end

  context 'when notification exists' do
    describe 'create more notifications' do
      before do
        first_notification.save
        second_notification.save
      end

      let(:second_notification) { build(:notification) }
      let(:errors) { second_notification.errors }

      it 'can not be created' do
        expect(second_notification.save).to be false
      end

      it 'return errors' do
        expect(errors).not_to be_empty
      end

      it 'return specific error message' do
        expect(errors.messages[:base]).to include('Only one notification is allowed')
      end
    end
  end
end
