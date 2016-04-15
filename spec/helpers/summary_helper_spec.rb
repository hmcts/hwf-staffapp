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
        expected = '<div class="summary-section"><div class="grid-row header-row"><div class="column-two-thirds"><h4 class="heading-medium util_mt-0">section name</h4></div></div><div class="grid-row"><div class="column-one-third">Fee</div><div class="column-two-thirds">£310</div></div></div>'
        expect(helper.build_section('section name', view, %w[fee])).to eq(expected)
      end

      context 'when link title and url is also passed' do
        let(:title) { 'TITLE' }
        let(:url) { 'URL' }

        it 'returns the correct html' do
          expected = "<div class=\"summary-section\"><div class=\"grid-row header-row\"><div class=\"column-two-thirds\"><h4 class=\"heading-medium util_mt-0\">section name</h4></div><div class=\"column-one-third\"><a class=\"right\" href=\"#{url}\">#{title}</a></div></div><div class=\"grid-row\"><div class=\"column-one-third\">Fee</div><div class=\"column-two-thirds\">£310</div></div></div>"
          expect(helper.build_section('section name', view, %w[fee], title, url)).to eq(expected)
        end
      end
    end
  end
end
