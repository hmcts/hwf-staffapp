require 'rails_helper'

RSpec.describe Query::LastUpdatedApplications, type: :model do
  subject(:query) { described_class.new(user) }

  let(:user) { create :user }

  describe '#find' do
    subject { query.find }

    let(:application1) { create :application_full_remission, user: user }
    let(:application2) { create :application_full_remission, :deleted_state, user: user, updated_at: Time.zone.parse('2015-10-19') }
    let(:application3) { create :application_full_remission, :deleted_state, user: user, updated_at: Time.zone.parse('2016-02-29') }

    before do
      application1
      application2
      application3
    end

    it "contains applications completely deleted from user's office in descending order of deletion" do
      is_expected.to eq([application1, application3, application2])
    end
  end
end
