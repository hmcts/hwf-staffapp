require 'rails_helper'

RSpec.describe SummaryHelper, type: :helper do

  it { expect(helper).to be_a described_class }

  describe '#build_section' do
    context 'when passed a name and an overview object' do
      let(:fee_label) { 'Fee' }
      let(:view) { double(fee: '£310') }

      before do
        i18n_key = 'activemodel.attributes.r_spec/mocks/double.fee'
        allow(I18n).to receive(:t).with(i18n_key).and_return(fee_label)
      end

      it 'returns the correct html' do
        expected = '<div class="summary-section"><div class="row"><div class="small-12 medium-7 large-8 columns"><h4>section name</h4></div></div><div class="row"><div class="small-12 medium-5 large-4 columns subheader">Fee</div><div class="small-12 medium-7 large-8 columns">£310</div></div></div>'
        expect(helper.build_section('section name', view, %w[fee])).to eq(expected)
      end

      context 'when link title and url is also passed' do
        let(:title) { 'TITLE' }
        let(:url) { 'URL' }

        it 'returns the correct html' do
          expected = "<div class=\"summary-section\"><div class=\"row\"><div class=\"small-12 medium-7 large-8 columns\"><h4>section name</h4></div><div class=\"small-12 medium-5 large-4 columns medium-text-right large-text-right\"><a href=\"#{url}\">#{title}</a></div></div><div class=\"row\"><div class=\"small-12 medium-5 large-4 columns subheader\">Fee</div><div class=\"small-12 medium-7 large-8 columns\">£310</div></div></div>"
          expect(helper.build_section('section name', view, %w[fee], title, url)).to eq(expected)
        end
      end
    end
  end
end
