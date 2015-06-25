require 'rails_helper'

RSpec.describe "offices/index", type: :view do
  include Devise::TestHelpers

  let(:user)          { create :user }
  let(:admin_user)    { create :admin_user }

  before(:each) do
    assign(:offices, create_list(:office, 2))
  end

  context 'logged in user' do

    before(:each) do
      sign_in user
      render
    end

    it 'not see the New Office link' do
      expect(rendered).to_not have_link('New Office', href: new_office_path)
    end

    it 'not see the edit or destroy links' do
      expect(rendered).to_not have_css('a', text: 'Edit')
    end
  end

  context 'logged in as admin' do

    before(:each) do
      sign_in admin_user
      render
    end

    it 'see the New office link' do
      expect(rendered).to have_link('New Office', href: new_office_path)
    end

    it 'see the edit and destroy links' do
      expect(rendered).to have_css('a', text: 'Edit', count: 2)
    end
  end
end
