require 'rails_helper'

RSpec.describe HmrcToken, type: :model do
  subject(:token) { HmrcToken.new(access_token: '123456', expires_in: expires_in) }
  let(:expires_in) { Time.parse('01-02-2021 10:55') }

  context 'expired?' do
    it 'no' do
      Timecop.freeze(Time.parse('01-02-2021 10:56')) do
        expect(token.expired?).to be_falsey
      end
    end

    it 'yes if nil' do
      token.expires_in = nil
      expect(token.expired?).to be_truthy
    end

    it 'yes' do
      Timecop.freeze(Time.parse('01-02-2021 10:54')) do
        expect(token.expired?).to be_truthy
      end
    end

  end


end
