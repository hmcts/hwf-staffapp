require 'rails_helper'

RSpec.describe OnlineApplication, type: :model do
  subject(:online_application) { build :online_application }

  it { is_expected.to validate_presence_of(:married) }
  it { is_expected.to validate_presence_of(:threshold_exceeded) }
  it { is_expected.to validate_presence_of(:benefits) }
  it { is_expected.to validate_presence_of(:children) }
  it { is_expected.to validate_presence_of(:refund) }
  it { is_expected.to validate_presence_of(:probate) }
  it { is_expected.to validate_presence_of(:ni_number) }
  it { is_expected.to validate_presence_of(:date_of_birth) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_presence_of(:email_contact) }
  it { is_expected.to validate_presence_of(:phone_contact) }
  it { is_expected.to validate_presence_of(:post_contact) }

  it { is_expected.to validate_uniqueness_of(:reference) }
end
