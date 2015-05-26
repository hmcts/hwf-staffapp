require 'rails_helper'

RSpec.describe 'dwp_checks/new.html.slim', type: :view do
  include Devise::TestHelpers

  let(:user)          { FactoryGirl.create :user }
  let(:check)      { FactoryGirl.build :dwp_check }

  it 'contain the required fields' do
    sign_in user
    @dwp_checker = check
    render
    assert_select 'form label', text: "#{t('activerecord.attributes.dwp_check.last_name')}#{t('activerecord.attributes.dwp_check.last_name_hint')}", count:  1
    assert_select 'form label', text: "#{t('activerecord.attributes.dwp_check.dob')}#{t('activerecord.attributes.dwp_check.dob_hint')}", count:  1
    assert_select 'form label', text: t('activerecord.attributes.dwp_check.ni_number').to_s, count:  1
    assert_select 'form label', text: "#{t('activerecord.attributes.dwp_check.date_to_check')}#{t('activerecord.attributes.dwp_check.date_to_check_hint')}", count:  1
  end
end
