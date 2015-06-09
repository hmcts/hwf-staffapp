require 'rails_helper'

RSpec.describe "home/index.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)      { create :user }
  let(:manager)   { create :manager }
  let(:admin)     { create :admin_user }

  context 'public access' do
    it 'shows a restriction message' do
      render
      expect(rendered).to have_xpath('//div', text: /This system is restricted/)
    end
  end

  context 'user access' do
    it 'displays guidance' do
      sign_in user
      render
      expect(rendered).to have_xpath('//span[@class="bold"]', text: /Check benefits/)
      expect(rendered).to have_xpath('//p', text: /eligible for benefits-based remission/)
    end
  end

  context 'manager access' do
    it 'displays a dwp checklist' do
      sign_in manager
      render
      expect(rendered).to have_xpath('//h2', text: /Manager summary for/)
      expect(rendered).to have_xpath('//th', text: 'Staff member')
    end
  end

  context 'admin access' do
    it 'displays graphs' do
      sign_in admin
      render
      expect(rendered).to have_xpath('//h2', text: 'Total')
    end
  end
end
