require 'rails_helper'

RSpec.feature 'Domain redirection', type: :feature do

  let(:domain_to_redirect) { 'trial.domain' }
  let(:domain) { 'production.domain' }

  scenario 'User accesses the system on the domain to redirect and is redirected' do
    visit "http://#{domain_to_redirect}"

    expect(page.current_host).to eql("http://#{domain}")
  end

  scenario 'User accesses the system on the final domain and is not redirected' do
    visit "http://#{domain}"

    expect(page.current_host).to eql("http://#{domain}")
  end
end
