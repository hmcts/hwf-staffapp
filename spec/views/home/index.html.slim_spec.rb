require 'rails_helper'

RSpec.describe "home/index.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)      { create :user }
  let(:manager)   { create :manager }
  let(:admin)     { create :admin_user }

  context 'public access' do
    it 'shows a get help message' do
      render
      expect(rendered).to have_xpath('//h4', text: /Get help/)
    end
  end

  context 'user access' do
    before do
      sign_in user
      render
    end

    it 'displays title' do
      expect(rendered).to have_text 'Process applications for help with fees'
    end

    it 'shows the start button' do
      expect(rendered).to have_link 'Start now'
    end
  end

  context 'manager access' do
    before do
      sign_in manager
      render
    end

    it 'has a link to staff' do
      expect(rendered).to have_link 'Staff overview'

    end

    it 'has a link to their office' do
      expect(rendered).to have_link 'Your Office'
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
