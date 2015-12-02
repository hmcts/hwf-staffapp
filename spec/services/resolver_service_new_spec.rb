require 'rails_helper'

describe ResolverService do
  let(:current_time) { Time.zone.now }
  let(:user) { create(:user) }
  let(:application_outcome) { 'part' }
  let(:application) { create(:application, :uncompleted, :undecided, outcome: application_outcome) }

  subject(:resolver) { described_class.new(object, user) }

  describe '#complete' do
    let(:evidence_check_decision) { false }
    let(:evidence_check_selector) { double(decide!: evidence_check_decision) }
    let(:part_payment_decision) { false }
    let(:part_payment_builder) { double(decide!: part_payment_decision) }

    before do
      allow(EvidenceCheckSelector).to receive(:new).with(application, Fixnum).and_return(evidence_check_selector)
      allow(PartPaymentBuilder).to receive(:new).with(application, Fixnum).and_return(part_payment_builder)
    end

    subject(:complete) do
      Timecop.freeze(current_time) do
        resolver.complete
      end
    end

    subject(:updated_application) do
      complete
      application.reload
    end

    shared_examples 'application, evidence check or part payment completed' do |type, state, decided|
      it 'sets completed_at for current time' do
        expect(send("updated_#{type}").completed_at).to eql(current_time)
      end

      it 'sets completed_by to be the user' do
        expect(send("updated_#{type}").completed_by).to eql(user)
      end

      it "sets state to be :#{state}" do
        expect(updated_application.state).to eql(state)
      end

      if decided
        it "sets decision from the #{type} outcome" do
          expect(updated_application.decision).to eql(send(type).outcome)
        end

        it 'sets decision_type to be application' do
          expect(updated_application.decision_type).to eql(type)
        end
      else
        it 'keeps the application undecided' do
          expect(updated_application.decision).to be nil
          expect(updated_application.decision_type).to be nil
        end
      end
    end

    context 'for Application' do
      let(:object) { application }

      context 'when the application does not have an outcome' do
        let(:application_outcome) { nil }

        it 'raises an error' do
          expect { complete }.to raise_error(ResolverService::UndefinedOutcome)
        end
      end

      context 'when the application needs evidence check' do
        let(:evidence_check_decision) { true }

        include_examples 'application, evidence check or part payment completed', 'application', 'evidence_check', false
      end

      context 'when the application needs part payment' do
        let(:part_payment_decision) { true }

        include_examples 'application, evidence check or part payment completed', 'application', 'part_payment', false
      end

      context 'when the application has outcome and does not need evidence check or part payment' do
        include_examples 'application, evidence check or part payment completed', 'application', 'processed', true
      end
    end

    context 'for EvidenceCheck' do
      subject(:updated_evidence_check) do
        complete
        evidence_check.reload
      end

      let(:object) { evidence_check }

      context 'when the evidence check does not have an outcome' do
        let(:evidence_check) { create :evidence_check, application: application }

        it 'raises an error' do
          expect { complete }.to raise_error(ResolverService::UndefinedOutcome)
        end
      end

      context 'when the application requires part payment' do
        let(:evidence_check) { create :evidence_check_part_outcome, application: application }
        let(:part_payment_decision) { true }

        include_examples 'application, evidence check or part payment completed', 'evidence_check', 'part_payment', false
      end

      context 'when the evidence check has outcome and application does not require part payment' do
        let(:evidence_check) { create :evidence_check_full_outcome, application: application }

        include_examples 'application, evidence check or part payment completed', 'evidence_check', 'processed', true
      end
    end

    context 'for PartPayment' do
      subject(:updated_part_payment) do
        complete
        part_payment.reload
      end

      let(:object) { part_payment }

      context 'when the part_payment does not have an outcome' do
        let(:part_payment) { create :part_payment, application: application }

        it 'raises an error' do
          expect { complete }.to raise_error(ResolverService::UndefinedOutcome)
        end
      end

      context 'when the evidence check has outcome' do
        let(:part_payment) { create :part_payment_part_outcome, application: application }

        include_examples 'application, evidence check or part payment completed', 'part_payment', 'processed', true
      end
    end
  end

  describe '#return' do
    subject(:return_method) do
      Timecop.freeze(current_time) do
        resolver.return
      end
    end

    subject(:updated_application) do
      return_method
      application.reload
    end

    subject(:updated_evidence_check) do
      return_method
      evidence_check.reload
    end

    subject(:updated_part_payment) do
      return_method
      part_payment.reload
    end

    shared_examples 'application, evidence check or part payment returned' do |type|
      it 'sets completed_at for current time' do
        expect(send("updated_#{type}").completed_at).to eql(current_time)
      end

      it 'sets completed_by to be the user' do
        expect(send("updated_#{type}").completed_by).to eql(user)
      end

      it 'sets the outcome to be return' do
        expect(send("updated_#{type}").outcome).to eql('return')
      end

      it 'sets state to be :processed' do
        expect(updated_application.state).to eql('processed')
      end

      it 'sets decision to be none' do
        expect(updated_application.decision).to eql('none')
      end

      it "sets decision_type to be #{type}" do
        expect(updated_application.decision_type).to eql(type)
      end
    end

    context 'for EvidenceCheck' do
      let(:evidence_check) { create :evidence_check, application: application }

      let(:object) { evidence_check }

      include_examples 'application, evidence check or part payment returned', 'evidence_check'
    end

    context 'for PartPayment' do
      let(:part_payment) { create :part_payment, application: application }

      let(:object) { part_payment }

      include_examples 'application, evidence check or part payment returned', 'part_payment'
    end
  end
end
