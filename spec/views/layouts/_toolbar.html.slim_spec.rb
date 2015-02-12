require 'spec_helper'

RSpec.describe "layouts/_toolbar.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  it 'should contain our header' do
    render
    expect(rendered).to include('Home')
  end

  context 'logged out user' do

    it 'should not show offices' do
      render
      expect(rendered).to_not include('Offices')
    end

    it 'should not show admin' do
      render
      expect(rendered).to_not include('Admin')
    end
  end

  context 'logged in as user' do

    before(:each) { sign_in user }

    it 'should not offices' do
      render
      expect(rendered).to  include('Offices')
    end

    it 'should show not admin' do
      render
      expect(rendered).to_not include('Admin')
    end
  end
  context 'logged in as admin' do

    before(:each) { sign_in admin_user }

    it 'should show offices' do
      render
      expect(rendered).to include('Offices')
    end

    it 'should show not admin' do
      render
      expect(rendered).to include('Admin')
    end
  end
end


