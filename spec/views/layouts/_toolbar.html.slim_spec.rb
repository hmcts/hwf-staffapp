require 'spec_helper'

RSpec.describe "layouts/_toolbar.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  it 'contain our header' do
    render
    expect(rendered).to include('Home')
  end

  context 'logged out user' do

    before(:each) { render }

    it 'not see offices' do
      expect(rendered).to_not include('Offices')
    end

    it 'not see admin' do
      expect(rendered).to_not include('Admin')
    end
  end

  context 'logged in user' do

    before(:each) do
      sign_in user
      render
    end

    it 'see offices' do
      expect(rendered).to include('Offices')
    end

    it 'not see admin' do
      expect(rendered).to_not include('Users')
    end
  end
  context 'logged in as admin' do

    before(:each) do
      sign_in admin_user
      render
    end

    it 'see offices' do
      expect(rendered).to include('Offices')
    end

    it 'see admin' do
      expect(rendered).to include('Users')
    end
  end
end
