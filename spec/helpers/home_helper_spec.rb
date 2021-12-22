require 'rails_helper'

RSpec.describe HomeHelper do
  # For some reason the request method is nil and hard to stub
  # so I created this method that helps with the testing.
  def request
    url = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=desc#new_completed_search'
    instance_double(ActionDispatch::Request, original_url: url)
  end

  describe '#path_for_application_based_on_state' do
    let(:evidence_check) { create(:evidence_check, application: last_application, income_check_type: check_type) }
    let(:part_payment) { create(:part_payment, application: last_application) }
    let(:check_type) { nil }

    context 'waiting_for_evidence' do
      context 'standard' do
        let(:last_application) { create(:application, :waiting_for_evidence_state) }
        before { evidence_check }

        it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence/#{evidence_check.id}") }
      end

      context 'hmrc check type' do
        let(:check_type) { 'hmrc' }
        let(:last_application) { create(:application, :waiting_for_evidence_state) }
        before { evidence_check }

        it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new") }

        context 'with hmrc but empty income' do
          before { hmrc_check }
          let(:hmrc_check) { create :hmrc_check, evidence_check: evidence_check, income: nil }
          it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/new") }
        end

        context 'with hmrc and income data' do
          before { hmrc_check }
          let(:income_hash) { [{ "grossEarningsForNics" => { "inPayPeriod1" => 12000.04 } }] }
          let(:hmrc_check) { create :hmrc_check, evidence_check: evidence_check, income: income_hash }
          it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence_checks/#{evidence_check.id}/hmrc/#{hmrc_check.id}") }
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
        let(:last_application) { create(:application, state: :created, online_application: online_application) }
        before { last_application }

        it { expect(path_for_application_based_on_state(last_application)).to eql("/online_applications/#{online_application.id}") }
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
