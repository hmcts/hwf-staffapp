require 'rails_helper'

RSpec.describe HomeHelper do
  # For some reason the request method is nil and hard to stub
  # so I created this method that helps with the testing.
  def request
    url = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=desc#new_completed_search'
    instance_double(ActionDispatch::Request, original_url: url)
  end

  describe '#path_for_application_based_on_state' do
    let(:evidence_check) { last_application.evidence_check }
    let(:part_payment) { create(:part_payment, application: last_application) }
    let(:check_type) { nil }
    let(:income_period) { nil }

    context 'waiting_for_evidence' do
      context 'standard' do
        let(:last_application) { create(:application, :waiting_for_evidence_state) }
        before { evidence_check.update(income_check_type: check_type) }

        it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence/#{evidence_check.id}") }
      end

      context 'hmrc check type' do
        let(:check_type) { 'hmrc' }
        let(:last_application) { create(:application, :waiting_for_evidence_state, income_period: income_period) }
        before { evidence_check.update(income_check_type: check_type) }

        it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new") }

        context 'with no hmrc' do
          it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new") }
        end

        context 'with hmrc check' do
          before { hmrc_check }

          let(:hmrc_check) { create(:hmrc_check, evidence_check: evidence_check) }
          it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/#{hmrc_check.id}") }

          context 'when hmrc check has error_response' do
            let(:hmrc_check) { create(:hmrc_check, evidence_check: evidence_check, error_response: 'HMRC error') }

            it 'redirects to new hmrc check page' do
              expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new")
            end
          end

          context 'when partner hmrc check has error_response' do
            let(:partner_check) do
              create(:hmrc_check, evidence_check: evidence_check, check_type: 'partner', error_response: 'HMRC error')
            end

            before { partner_check }

            it 'redirects to new hmrc check page' do
              expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new")
            end
          end

          context 'when applicant passes but partner fails' do
            let(:hmrc_check) { create(:hmrc_check, evidence_check: evidence_check, error_response: nil) }
            let(:partner_check) do
              create(:hmrc_check, evidence_check: evidence_check, check_type: 'partner', error_response: 'HMRC error')
            end

            before { partner_check }

            it 'redirects to new hmrc check page' do
              expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new")
            end
          end
        end

      end
    end

    context 'waiting_for_part_payment' do
      let(:last_application) { create(:application, :waiting_for_part_payment_state) }
      before { part_payment }

      it { expect(path_for_application_based_on_state(last_application)).to eql("/part_payments/#{part_payment.id}") }
    end

    context 'dwp_failed' do
      context 'online application' do
        let(:online_application) { create(:online_application) }
        it { expect(path_for_application_based_on_state(online_application)).to eql("/online_applications/#{online_application.id}/edit") }
      end

      context 'paper application' do
        let(:last_application) { create(:application, state: :created) }

        it { expect(path_for_application_based_on_state(last_application)).to eql("/applications/#{last_application.id}/personal_informations") }
      end
    end
  end

  describe '#sort_link_class' do
    it { expect(sort_link_class('name', 'first_name')).to eql 'sort_arrows' }
    it { expect(sort_link_class('first_name', 'first_name')).to eql 'sort_arrow_desc' }

    describe 'with correct sort_direction' do
      it { expect(sort_link_class('first_name', 'first_name', 'desc')).to eql 'sort_arrow_asc' }

      it do
        expect(sort_link_class('first_name', 'first_name', 'asc')).to eql 'sort_arrow_desc'
      end
    end
  end

  describe '#sort_link_helper' do
    it "replacing the sort direction if the sort param match" do
      new_link = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=asc#new_completed_search'
      expect(sort_link_helper('first_name', 'first_name', 'desc')).to eql(new_link)
    end

    it "no replacing the sort direction" do
      @sort_to = 'asc'
      @sort_by = 'first_name'
      new_link = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=last_name&sort_to=asc#new_completed_search'
      expect(sort_link_helper('last_name', 'first_name', 'asc')).to eql(new_link)
    end
  end
end
