require 'rails_helper'
require 'support/calculator_test_data'

RSpec.describe Application, type: :model do

  let(:user)  { create :user }
  let(:attributes) { attributes_for :application }
  let(:applicant) { create(:applicant) }
  let(:detail) { create(:detail) }
  subject(:application) { described_class.create(user_id: user.id, reference: attributes[:reference], applicant: applicant, detail: detail) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:office) }

  it { is_expected.to have_one(:applicant) }
  it { is_expected.to have_one(:detail) }

  it { is_expected.to have_one(:evidence_check) }
  it { is_expected.not_to validate_presence_of(:evidence_check) }

  it { is_expected.to have_one(:part_payment) }
  it { is_expected.not_to validate_presence_of(:part_payment) }

  it { is_expected.to validate_presence_of(:reference) }
  it { is_expected.to validate_uniqueness_of(:reference) }

  it { is_expected.to define_enum_for(:state).with([:created, :evidence_check, :part_payment, :processed]) }

  it { is_expected.to delegate_method(:applicant_age).to(:applicant).as(:age) }

  describe 'temporary methods delegation to sliced models' do
    let(:param) { true }

    describe '-> Applicant' do
      described_class::APPLICANT_GETTERS.each do |getter|
        it { is_expected.to delegate_method(getter).to(:applicant) }
      end

      described_class::APPLICANT_SETTERS.each do |setter|
        it "should delegate #{setter} to #applicant object" do
          expect(applicant).to receive(setter).with(param)
          application.send(setter, param)
        end
      end
    end

    describe '-> Detail' do
      described_class::DETAIL_GETTERS.each do |getter|
        it { is_expected.to delegate_method(getter).to(:detail) }
      end

      described_class::DETAIL_SETTERS.each do |setter|
        it "should delegate #{setter} to #detail object" do
          # this is a hack to make sure the bellow expectation is not tested when the factories are being created
          application

          expect(detail).to receive(setter).with(param)
          application.send(setter, param)
        end
      end
    end
  end

  describe '#emergency_reason' do
    context 'when a blank string is provided' do
      let(:application) { create :application_full_remission }

      it "doesn't save it as a string" do
        application.reload
        expect(application.emergency_reason).to be nil
      end
    end
  end

  describe '#threshold' do
    subject { application.threshold }

    context 'when applicant is over 61' do
      let(:applicant) { create(:applicant, :over_61) }

      it 'returns 16000' do
        is_expected.to eq(16000)
      end
    end

    context 'when applicant is under 61' do
      let(:applicant) { create(:applicant, :under_61) }
      let(:fee_threshold) { double(band: 845) }

      before do
        allow(FeeThreshold).to receive(:new).with(application.fee).and_return(fee_threshold)
      end

      it 'calculates the threshold from the fee' do
        is_expected.to eq(845)
      end
    end
  end
end
