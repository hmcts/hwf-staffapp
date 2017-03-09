require 'rails_helper'

describe ResolverService do
  subject(:resolver) { described_class.new(object, user) }

  let(:current_time) { Time.zone.now.change(usec: 0) }
  let(:user) { create(:user) }
  let(:application_outcome) { 'part' }
  let(:fee) { 350 }
  let(:amount_to_pay) { nil }
  let(:existing_reference) { nil }
  let(:application) do
    create(:application, :uncompleted, :undecided,
      fee: fee, amount_to_pay: amount_to_pay, outcome: application_outcome, reference: existing_reference)
  end

  describe '#complete' do
    subject(:complete) do
      Timecop.freeze(current_time) do
        resolver.complete
      end
    end

    subject(:updated_application) do
      complete
      application.reload
    end

    let(:evidence_check_decision) { false }
    let(:evidence_check_selector) { instance_double(EvidenceCheckSelector, decide!: evidence_check_decision) }
    let(:part_payment_decision) { false }
    let(:part_payment_builder) { instance_double(PartPaymentBuilder, decide!: part_payment_decision) }

    before do
      allow(EvidenceCheckSelector).to receive(:new).with(application, Integer).and_return(evidence_check_selector)
    end

    shared_examples 'application, evidence check or part payment completed' do |type, state, decided, cost|
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

        it 'sets decision_date to current time' do
          expect(updated_application.decision_date).to eql(current_time)
        end

        it 'sets decision_cost' do
          expect(updated_application.decision_cost).to eql(cost)
        end
      else
        describe 'keeps the application undecided' do
          it { expect(updated_application.decision).to be nil }
          it { expect(updated_application.decision_type).to be nil }
          it { expect(updated_application.decision_date).to be nil }
          it { expect(updated_application.decision_cost).to be nil }
        end
      end
    end

    shared_examples 'application reference and business_entity' do
      context 'when the application has reference number already' do
        let(:existing_reference) { 'SOME_REFERENCE' }

        it 'does not generate a new reference' do
          expect(updated_application.reference).to eql(existing_reference)
        end

        it 'stores the business entity' do
          expect(updated_application.business_entity).to eql(business_entity)
        end
      end

      context 'when the application does not have a reference number' do
        it 'generates and stores the reference' do
          expect(updated_application.reference).to eql(reference)
        end

        it 'stores the business entity' do
          expect(updated_application.business_entity).to eql(business_entity)
        end
      end
    end

    context 'for Application' do
      let(:reference) { 'ABC' }
      let(:business_entity) { create(:business_entity) }
      let(:be_generator) { instance_double(BusinessEntityGenerator, attributes: { business_entity: business_entity }) }
      let(:generator) { instance_double(ReferenceGenerator, attributes: { reference: reference }) }

      let(:object) { application }

      before do
        allow(BusinessEntityGenerator).to receive(:new).and_return(be_generator)
        allow(ReferenceGenerator).to receive(:new).and_return(generator)
        allow(PartPaymentBuilder).to receive(:new).with(application, Integer).and_return(part_payment_builder)
      end

      context 'when the application does not have an outcome' do
        let(:application_outcome) { nil }

        it 'raises an error' do
          expect { complete }.to raise_error(ResolverService::UndefinedOutcome)
        end
      end

      context 'when the application needs evidence check' do
        let(:evidence_check_decision) { true }

        include_examples 'application, evidence check or part payment completed', 'application', 'waiting_for_evidence', false

        include_examples 'application reference and business_entity'

        it 'stores the business entity used to generate the reference' do
          expect(updated_application.business_entity).to eql(business_entity)
        end
      end

      context 'when the application needs part payment' do
        let(:part_payment_decision) { true }

        include_examples 'application, evidence check or part payment completed', 'application', 'waiting_for_part_payment', false

        include_examples 'application reference and business_entity'

        it 'stores the business entity used to generate the reference' do
          expect(updated_application.business_entity).to eql(business_entity)
        end
      end

      context 'when the application has outcome and does not need evidence check or part payment' do
        context 'for a full outcome' do
          let(:application_outcome) { 'full' }

          include_examples 'application, evidence check or part payment completed', 'application', 'processed', true, 350
        end

        context 'for a none outcome' do
          let(:application_outcome) { 'none' }

          include_examples 'application, evidence check or part payment completed', 'application', 'processed', true, 0
        end

        include_examples 'application reference and business_entity'
      end

      context 'duplicated reference' do
        let(:application_outcome) { 'full' }
        let(:reference) { 'ABC' }
        let!(:application_old) { create(:application, reference: reference) }

        it "raise an error" do
          expect{ complete }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

    end

    context 'for EvidenceCheck' do
      subject(:updated_evidence_check) do
        complete
        evidence_check.reload
      end

      let(:object) { evidence_check }

      before do
        allow(PartPaymentBuilder).to receive(:new).with(evidence_check, Integer).and_return(part_payment_builder)
      end

      context 'when the evidence check does not have an outcome' do
        let(:evidence_check) { create :evidence_check, application: application }

        it 'raises an error' do
          expect { complete }.to raise_error(ResolverService::UndefinedOutcome)
        end
      end

      context 'when the application requires part payment' do
        let(:evidence_check) { create :evidence_check_part_outcome, application: application }
        let(:part_payment_decision) { true }

        include_examples 'application, evidence check or part payment completed', 'evidence_check', 'waiting_for_part_payment', false
      end

      context 'when the evidence check has outcome and application does not require part payment' do
        context 'for full outcome' do
          let(:evidence_check) { create :evidence_check_full_outcome, application: application }

          include_examples 'application, evidence check or part payment completed', 'evidence_check', 'processed', true, 350
        end

        context 'for none outcome' do
          let(:evidence_check) { create :evidence_check_incorrect, application: application }

          include_examples 'application, evidence check or part payment completed', 'evidence_check', 'processed', true, 0
        end

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

      context 'when the part payment has outcome' do
        context 'for a part outcome' do
          let(:part_payment) { create :part_payment_part_outcome, application: application }

          context 'when the application also was evidence checked' do
            before do
              create(:evidence_check_part_outcome, :completed, application: application, amount_to_pay: 150)
            end

            include_examples 'application, evidence check or part payment completed', 'part_payment', 'processed', true, 200
          end

          context 'when the application was not evidence checked' do
            let(:amount_to_pay) { 50 }

            include_examples 'application, evidence check or part payment completed', 'part_payment', 'processed', true, 300
          end
        end

        context 'for a none outcome' do
          let(:part_payment) { create :part_payment_none_outcome, application: application }

          include_examples 'application, evidence check or part payment completed', 'part_payment', 'processed', true, 0
        end
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

      it 'sets the decision_cost to 0' do
        expect(updated_application.decision_cost).to eq 0
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

  describe '#delete' do
    subject(:delete) do
      Timecop.freeze(current_time) do
        resolver.delete
      end
    end

    let(:object) { application }

    context 'when the application state is :processed and it has :deleted_reason set' do
      subject(:deleted_application) do
        delete
        application.reload
      end

      let(:application) { create :application, :processed_state, deleted_reason: 'I do not like it' }

      it 'moves the application to :deleted state' do
        expect(deleted_application).to be_deleted
      end

      it 'sets deleted_at for current time' do
        expect(deleted_application.deleted_at).to eql(current_time)
      end

      it 'sets deleted_by to be the user' do
        expect(deleted_application.deleted_by).to eql(user)
      end
    end

    context 'when the application is not in :processed state' do
      let(:application) { create :application, :waiting_for_evidence_state }

      it 'raises an error' do
        expect { delete }.to raise_error(ResolverService::NotDeletable)
      end
    end

    context 'when the :deleted_reason is missing' do
      let(:application) { create :application, :processed_state, deleted_reason: nil }

      it 'raises an error' do
        expect { delete }.to raise_error(ResolverService::NotDeletable)
      end
    end
  end
end
