require 'rails_helper'

RSpec.describe OnlineApplication, type: :model do
  subject(:online_application) { build :online_application }

  it { is_expected.to validate_presence_of(:children) }
  it { is_expected.to validate_presence_of(:ni_number) }
  it { is_expected.to validate_presence_of(:date_of_birth) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_presence_of(:postcode) }

  it { is_expected.not_to allow_value(nil).for(:married) }
  it { is_expected.not_to allow_value(nil).for(:threshold_exceeded) }
  it { is_expected.not_to allow_value(nil).for(:benefits) }
  it { is_expected.not_to allow_value(nil).for(:refund) }
  it { is_expected.not_to allow_value(nil).for(:probate) }
  it { is_expected.not_to allow_value(nil).for(:email_contact) }
  it { is_expected.not_to allow_value(nil).for(:phone_contact) }
  it { is_expected.not_to allow_value(nil).for(:post_contact) }

  it { is_expected.to validate_uniqueness_of(:reference) }
end
