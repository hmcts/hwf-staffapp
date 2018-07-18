require 'rails_helper'

RSpec.describe DwpWarning, type: :model do
  let(:dwp_warning) { build :dwp_warning }

  it "has a default value" do
    expect(dwp_warning.check_state).to eql(DwpWarning::STATES[:default_checker])
  end

  describe 'Use default check?' do
    it { expect(DwpWarning.use_default_check?).to be_truthy }

    context 'online' do
      before { create :dwp_warning, check_state: DwpWarning::STATES[:online] }

      it { expect(DwpWarning.use_default_check?).to be_falsey }
    end

    context 'offline' do
      before { create :dwp_warning, check_state: DwpWarning::STATES[:offline] }

      it { expect(DwpWarning.use_default_check?).to be_falsey }
    end
  end
end
