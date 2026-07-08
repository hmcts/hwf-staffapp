require 'rails_helper'

# Guards the CookieOverflow fix: sessions must live server-side (cache-backed by
# Redis), not in the 4KB cookie. If someone reverts to :cookie_store these fail.
RSpec.describe 'Session store configuration' do # rubocop:disable RSpec/DescribeClass
  it 'stores sessions server-side rather than in the size-limited cookie' do
    expect(Rails.application.config.session_store).to eq(ActionDispatch::Session::CacheStore)
  end

  it 'backs the session store with a dedicated Redis cache' do
    expect(Rails.application.config.session_options[:cache]).to be_a(ActiveSupport::Cache::RedisCacheStore)
  end

  it 'keeps the existing session cookie key' do
    expect(Rails.application.config.session_options[:key]).to eq('_fr-staffapp_session')
  end

  it 'expires server-side sessions in line with the Devise timeout' do
    expect(Rails.application.config.session_options[:expire_after]).to eq(1.hour)
  end

  it 'registers the cache session store in the middleware stack' do
    expect(Rails.application.middleware.map(&:name)).to include('ActionDispatch::Session::CacheStore')
  end
end
