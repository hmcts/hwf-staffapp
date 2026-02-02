require 'rails_helper'

describe EvidenceCheckSelector do
  subject(:evidence_check_selector) { described_class.new(application, expires_in_days) }

  let(:current_time) { Time.zone.local(2026, 1, 15, 12, 30, 0) }
  let(:expires_in_days) { 2 }
  let(:applicant) { application.applicant }

  describe '#decide!' do
    subject(:decision) do
      travel_to(current_time) do
        evidence_check_selector.decide!
      end

      application.evidence_check
    end

    context 'for a benefit application' do
      let(:application) { create(:application, :applicant_full) }

      before do
        create_list(:application, 9)
      end

      it 'never selects the application for evidence_check' do
        is_expected.to be_nil
      end
    end

    context 'for an application without remission' do
      let(:application) { create(:application_no_remission, :no_benefits) }

      before do
        create_list(:application_no_remission, 9, :no_benefits)
      end

      it 'never selects the application for evidence_check' do
        is_expected.to be_nil
      end
    end

    context 'for a non-benefit remission application' do
      context 'for a non-refund application' do

        context 'frequency test with stubs' do
          let(:query_checkeable) { instance_double(Query::EvidenceCheckable) }

          before do
            allow(Query::EvidenceCheckable).to receive(:new).and_return(query_checkeable)
            allow(query_checkeable).to receive(:list).and_return list
          end

          let(:evidence) { instance_double(EvidenceCheck, check_type: 'random') }
          let(:app_ev_check) { instance_double(Application, evidence_check: evidence) }
          let(:app_no_ev_check) { instance_double(Application, evidence_check: nil) }

          context 'frequency 2' do
            let(:application) { create(:application_full_remission, :refund, income: 150) }

            context '2nd' do
              let(:list) { [app_ev_check, app_no_ev_check] }

              it { is_expected.to be_a(EvidenceCheck) }
              it { expect(decision.check_type).to eql 'random' }

              it 'sets expiration on the evidence_check' do
                expect(decision.expires_at).to eql(current_time + expires_in_days.days)
              end

              it 'does not saves the ccmcc check type' do
                expect(decision.checks_annotation).to be_nil
              end

              context 'hmrc income check type' do
                before { allow(application).to receive(:hmrc_check_type?).and_return true }

                it { expect(decision.check_type).to eql 'random' }
                it { expect(decision.income_check_type).to eql 'hmrc' }

                context 'average income' do
                  let(:application) { create(:application_full_remission, :refund, income_period: 'average') }
                  it { expect(decision.income_check_type).to eql 'hmrc' }
                end
              end

            end
            context '1st' do
              let(:list) { [app_no_ev_check, app_ev_check] }

              it { is_expected.not_to be_a(EvidenceCheck) }
            end
            context 'no previous check' do
              let(:list) { [app_no_ev_check, app_no_ev_check] }

              it { is_expected.to be_a(EvidenceCheck) }
            end
            context 'empty list' do
              let(:list) { [] }

              it { is_expected.not_to be_a(EvidenceCheck) }
            end
          end

          context 'frequency 10' do
            let(:application) { create(:application_full_remission, :refund, income: 150) }

            context '10th' do
              let(:list) {
                [app_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check,
                 app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check]
              }

              it { is_expected.to be_a(EvidenceCheck) }
              it { expect(decision.check_type).to eql 'random' }

              it 'sets expiration on the evidence_check' do
                expect(decision.expires_at).to eql(current_time + expires_in_days.days)
              end

              it 'does not saves the ccmcc check type' do
                expect(decision.checks_annotation).to be_nil
              end

            end
            context '8th' do
              let(:list) {
                [app_no_ev_check, app_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check,
                 app_no_ev_check, app_no_ev_check, app_ev_check, app_no_ev_check]
              }

              it { is_expected.not_to be_a(EvidenceCheck) }
            end
            context '1st' do
              let(:list) {
                [app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check,
                 app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_ev_check]
              }

              it { is_expected.not_to be_a(EvidenceCheck) }
            end
            context 'no previous check' do
              let(:list) {
                [app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check,
                 app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check, app_no_ev_check]
              }

              it { is_expected.to be_a(EvidenceCheck) }
            end

            context 'empty list' do
              let(:list) { [] }

              it { is_expected.not_to be_a(EvidenceCheck) }
            end
          end
        end
      end

      context 'when the application is flagged for failed evidence check' do
        describe 'with ni_number' do
          let(:application) { create(:application_full_remission, :applicant_full, ni_number: 'SN123456D', reference: 'XY55-22-3') }
          before { create(:evidence_check_flag, reg_number: 'SN123456D') }

          it { is_expected.to be_a(EvidenceCheck) }

          it 'sets the type to "flag"' do
            expect(decision.check_type).to eql 'flag'
          end
        end

        describe 'with ho_number' do
          let(:application) { create(:application_full_remission, :applicant_full, reference: 'L123456', ni_number: '', ho_number: 'L123456') }
          before { create(:evidence_check_flag, reg_number: applicant.ho_number) }

          it { is_expected.to be_a(EvidenceCheck) }

          it 'sets the type to "flag"' do
            expect(decision.check_type).to eql 'flag'
          end
        end
      end

      context 'for a application with existing check and same ni_number' do
        let(:evidence_check) { application_old.evidence_check }
        let(:application_old) do
          create(:application, :income_type, :applicant_full, :waiting_for_evidence_state,
                 ni_number: 'SN123456D')
        end
        let(:applicant_old) { application_old.applicant }

        let(:application) {
          create(:application, :income_type, :applicant_full,
                 ni_number: 'SN123456D', date_of_birth: 20.years.ago)
        }

        before do
          evidence_check
        end

        it 'selects the application for evidence_check' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context 'for a application with existing check and same ni_number with inactive flag' do
        let(:evidence_check) { application_old.evidence_check }
        let(:application_old) do
          create(:application, :income_type, :applicant_full, :waiting_for_evidence_state,
                 ni_number: 'SN123456D')
        end
        let(:applicant_old) { application_old.applicant }

        let(:application) {
          create(:application, :income_type, :applicant_full,
                 ni_number: 'SN123456D', date_of_birth: 20.years.ago)
        }

        before do
          create(:evidence_check_flag, reg_number: applicant.ni_number, active: false)
          evidence_check
        end

        it 'selects the application for evidence_check' do
          is_expected.not_to be_a(EvidenceCheck)
        end
      end

      context 'for a application with existing check and same ho_number' do
        let(:evidence_check) { application_old.evidence_check }
        let(:application_old) do
          create(:application, :income_type, :waiting_for_evidence_state, :applicant_full,
                 ho_number: 'L123456', date_of_birth: 20.years.ago, ni_number: '')
        end
        let(:applicant_old) { application_old.applicant }

        let(:application) {
          create(:application, :income_type, :applicant_full,
                 ho_number: 'L123456', date_of_birth: 20.years.ago, ni_number: '')
        }

        before do
          evidence_check
        end

        it 'selects the application for evidence_check' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context "when applicant's ni number is empty" do
        it 'skips the ni_exist evidence check' do
          application = create(:application, :applicant_full, ni_number: '')

          create(:application, :income_type, :waiting_for_evidence_state, :applicant_full, ni_number: '')

          decision = described_class.new(application, expires_in_days).decide!

          expect(decision).not_to be_a(EvidenceCheck)
        end
      end
    end

    context 'Zero or Low income applies' do
      let(:application) { create(:application_full_remission, office: office, income: income) }
      let(:query_type) { nil }
      let(:frequency) { 1 }

      context 'not excluded office' do
        let(:office) { create(:office, entity_code: 'dig') }
        context 'under 101' do
          let(:income) { 50 }
          it { is_expected.to be_a(EvidenceCheck) }
          it { expect(decision.checks_annotation).to eq(LowIncomeEvidenceCheckRules::ANNOTATION) }
        end
        context 'equal 101' do
          let(:income) { 101 }
          it { is_expected.to be_a(EvidenceCheck) }
        end
        context 'under 102' do
          let(:income) { 102 }
          it { is_expected.not_to be_a(EvidenceCheck) }
        end
      end

      context 'excluded office' do
        let(:office) { create(:office, entity_code: 'TI122') }
        context 'under 101' do
          let(:income) { 11 }
          it { is_expected.not_to be_a(EvidenceCheck) }
          it { is_expected.not_to be_a(EvidenceCheck) }
        end
      end
    end

    context 'CCMCC application frequency applies' do
      let(:application) { create(:application_full_remission, office: ccmcc_office, income: 150) }
      let(:query_type) { nil }
      let(:frequency) { 1 }
      let(:ccmcc_office) { create(:office, entity_code: 'DH403') }
      let(:digital_office) { create(:office, entity_code: 'dig') }

      before do
        @ccmcc = instance_double(CCMCCEvidenceCheckRules, clean_annotation_data: true)
        allow(CCMCCEvidenceCheckRules).to receive(:new).and_return @ccmcc
        allow(@ccmcc).to receive_messages(rule_applies?: true, frequency: frequency, check_type: '5k rule', query_type: query_type)
      end

      context 'frequency is calculated against the ccmcc office only' do
        let(:frequency) { 2 }
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }

        context 'digital_office' do
          context 'just refund' do
            let(:application) { create(:application_full_remission, :refund, office: ccmcc_office, income: 150) }

            before do
              create(:application_full_remission, :refund, office: digital_office)
              create(:application_full_remission, office: digital_office)
            end

            let(:query_type) { CCMCCEvidenceCheckRules::QUERY_REFUND }

            it 'creates evidence_check record for the application' do
              is_expected.not_to be_a(EvidenceCheck)
            end
          end

          context 'just normal' do
            before do
              create(:application_full_remission, :refund, office: digital_office)
              create(:application_full_remission, office: digital_office)
            end

            let(:query_type) { nil }

            it 'creates evidence_check record for the application' do
              is_expected.not_to be_a(EvidenceCheck)
            end
          end

          context 'all' do
            let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }
            before do
              create_list(:application_full_remission, 2, :refund, office: digital_office)
              create(:application_full_remission, office: digital_office)
            end

            it 'creates evidence_check record for the application' do
              is_expected.not_to be_a(EvidenceCheck)
            end
          end
        end
      end

      context 'query all' do
        let(:frequency) { 2 }
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }

        before do
          create(:application_full_remission, :refund, office: ccmcc_office)
          create(:application, office: ccmcc_office)
          create(:application, office: digital_office)
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context 'query all with singe existing application' do
        let(:frequency) { 1 }
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }

        before do
          create(:application, office: ccmcc_office)
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context 'query only non refund applications' do
        before do
          create_list(:application_full_remission, 4, office: ccmcc_office)
          create_list(:application, 5, office: ccmcc_office)
          create(:application, office: digital_office)
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end

        it 'saves the ccmcc check type' do
          expect(decision.checks_annotation).to eq('5k rule')
        end
      end

      context 'query only refund applications' do
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_REFUND }
        before do
          create_list(:application_full_remission, 4, :refund, office: ccmcc_office)
          create_list(:application, 5, office: ccmcc_office)
          create(:application, :refund, office: digital_office)
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end

        it 'saves the ccmcc check type' do
          expect(decision.checks_annotation).to eq('5k rule')
        end

        it "don't clean annotaiton data" do
          decision
          expect(@ccmcc).not_to have_received(:clean_annotation_data)
        end
      end

      context 'the frequency does not match' do
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_REFUND }
        let(:frequency) { 3 }

        before do
          create(:application_full_remission, :refund, office: ccmcc_office)
          create(:application_full_remission_ev, :refund, office: ccmcc_office)
          create(:application_full_remission, :refund, office: ccmcc_office)
        end

        it 'cleans the ccmcc annotation data' do
          decision
          expect(@ccmcc).to have_received(:clean_annotation_data)
        end
      end
    end

  end
end
