require 'spec_helper'

RSpec.describe "dwp_checker/new.html.slim", type: :view do
  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user }
  let(:check)      { FactoryGirl.build :dwp_check }

  it 'should contain the required fields' do
    sign_in user
    @dwp_checker = check
    render
    assert_select 'form label', :text => 'Last Name'.to_s, :count => 1
    assert_select 'form label', :text => 'Date of Birth'.to_s, :count => 1
    assert_select 'form label', :text => 'NI Number'.to_s, :count => 1
    assert_select 'form label', :text => 'Date fee paid'.to_s, :count => 1
  end
end
