require 'rails_helper'

RSpec.describe HomeHelper do
  # For some reason the request method is nil and hard to stub
  # so I created this method that helps with the testing.
  def request
    url = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=desc#new_completed_search'
    instance_double(ActionDispatch::Request, original_url: url)
  end

  describe '#path_for_application_based_on_state' do
    let(:evidence_check) { create(:evidence_check, application: last_application) }
    let(:part_payment) { create(:part_payment, application: last_application) }

    context 'waiting_for_evidence' do
      let(:last_application) { create(:application, :waiting_for_evidence_state) }
      before { evidence_check }

      it { expect(path_for_application_based_on_state(last_application)).to eql("/evidence/#{evidence_check.id}") }
    end

    context 'waiting_for_part_payment' do
      let(:last_application) { create(:application, :waiting_for_part_payment_state) }
      before { part_payment }

      it { expect(path_for_application_based_on_state(last_application)).to eql("/part_payments/#{part_payment.id}") }
    end
  end

  describe '#sort_link_class' do
    before { @sort_by = 'first_name' }
    it { expect(sort_link_class('name')).to eql 'sort_arrows' }
    it { expect(sort_link_class('first_name')).to eql 'sort_arrow_desc' }

    describe 'with correct sort_direction' do
      before { @sort_to = 'desc' }
      it { expect(sort_link_class('first_name')).to eql 'sort_arrow_asc' }
      it do
        @sort_to = 'asc'
        expect(sort_link_class('first_name')).to eql 'sort_arrow_desc'
      end
    end
  end

  describe '#sort_link_helper' do
    it "replacing the sort direction if the sort param match" do
      @sort_to = 'desc'
      @sort_by = 'first_name'
      new_link = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=first_name&sort_to=asc#new_completed_search'
      expect(sort_link_helper('first_name')).to eql(new_link)
    end

    it "no replacing the sort direction" do
      @sort_to = 'asc'
      @sort_by = 'first_name'
      new_link = 'http://localhost:3000/home/completed_search?completed_search&reference=Philip&commit=Search&sort_by=last_name&sort_to=asc#new_completed_search'
      expect(sort_link_helper('last_name')).to eql(new_link)
    end
  end
end
