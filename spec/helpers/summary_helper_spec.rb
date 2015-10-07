require 'rails_helper'

RSpec.describe SummaryHelper, type: :helper do

  it { expect(helper).to be_a described_class }

  describe '#build_section' do
    context 'when passed a name and an overview object' do
      let(:name) { 'Section name' }
      let(:evidence) { build_stubbed(:evidence_check) }
      let(:overview) { Evidence::Views::Overview.new(evidence) }
      it 'returns the correct html' do
        expected = '<div class="summary-section"><div class="row"><div class="small-12 medium-7 large-8 columns"><h4>section name</h4></div></div><div class="row"><div class="small-12 medium-5 large-4 columns subheader">Fee</div><div class="small-12 medium-7 large-8 columns">£310</div></div></div>'
        expect(helper.build_section('section name', overview, %w[fee])).to eq(expected)
      end
    end
  end
end
