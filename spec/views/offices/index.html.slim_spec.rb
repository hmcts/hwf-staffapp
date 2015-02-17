require 'rails_helper'

RSpec.describe "offices/index", type: :view do
  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  before(:each) do
    assign(:offices, [
      Office.create!(
        :name => "Name"
      ),
      Office.create!(
        :name => "Name"
      )
    ])
  end

  context 'logged in user' do

    before(:each) do
      sign_in user
      render
    end

    it 'should not see the New Office link' do
      expect(rendered).to_not have_link('New Office', href: new_office_path)
    end

    it 'should not see the edit or destroy links' do
      expect(rendered).to_not have_css('a', :text => 'Edit')
      expect(rendered).to_not have_css('a', :text => 'Destroy')
    end
  end

  context 'logged in as admin' do

    before(:each) do
      sign_in admin_user
      render
    end

    it 'should see the New office link' do
      expect(rendered).to have_link('New Office', href: new_office_path)
    end

    it 'should see the edit and destroy links' do
      expect(rendered).to have_css('a', :text => 'Edit', count: 2)
      expect(rendered).to have_css('a', :text => 'Destroy', count: 2)
    end

  end

end

