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

    before(:each) { sign_in user }

    it 'does not see New Office link' do
      render
      expect(rendered).to_not include('New Office')
    end
  end

  context 'logged in as admin' do

    before(:each) { sign_in admin_user }

    it 'sees New office list' do
      render
      expect(rendered).to include('New Office')
    end

  end

end

