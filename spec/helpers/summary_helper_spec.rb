require 'rails_helper'

RSpec.describe SummaryHelper, type: :helper do

  let(:fee_label) { 'Fee' }

  before do
    i18n_key = 'activemodel.attributes.r_spec/mocks/instance_verifying_double.'
    i18n_fee = "#{i18n_key}fee"
    i18n_name = "#{i18n_key}form_name"
    i18n_date = "#{i18n_key}date_received"
    allow(I18n).to receive(:t).with(i18n_fee).and_return('Fee')
    allow(I18n).to receive(:t).with(i18n_name).and_return('Form name')
    allow(I18n).to receive(:t).with(i18n_date).and_return('Date received')
  end

  it { expect(helper).to be_a described_class }

  describe 'build_section_with_defaults' do
    let(:view) { instance_double(Views::Overview::Details, fee: '£310', all_fields: ['fee']) }

    context 'when called with minimal data' do
      it 'returns the correct html' do
        expected = '<div class="summary-section"><div class="grid-row header-row"><div class="column-two-thirds"><h4 class="heading-medium util_mt-0">section name</h4></div></div><div class="grid-row"><div class="column-one-third">Fee</div><div class="column-two-thirds">£310</div></div></div>'
        expect(helper.build_section_with_defaults('section name', view)).to eq(expected)
      end
    end
  end

  describe '#build_section' do

    context 'handles nil data fields' do
      let(:view) { instance_double(Views::Overview::Details, fee: '£310', form_name: '', date_received: nil) }

      context 'when requested fields all contain nil data' do
        it 'returns nothing' do
          expect(helper.build_section('section name', view, ['form_name', 'date_received'])).to be nil
        end
      end

      context 'when requested fields contain some data' do
        it 'returns only the populated field' do
          expected = '<div class="summary-section"><div class="grid-row header-row"><div class="column-two-thirds"><h4 class="heading-medium util_mt-0">section name</h4></div></div><div class="grid-row"><div class="column-one-third">Fee</div><div class="column-two-thirds">£310</div></div></div>'
          expect(helper.build_section('section name', view, ['fee', 'form_name', 'date_received'])).to eq(expected)
        end
      end
    end

    context 'when passed a name and an overview object' do
      let(:view) { instance_double(Views::Overview::Details, fee: '£310') }

      it 'returns the correct html' do
        expected = '<div class="summary-section"><div class="grid-row header-row"><div class="column-two-thirds"><h4 class="heading-medium util_mt-0">section name</h4></div></div><div class="grid-row"><div class="column-one-third">Fee</div><div class="column-two-thirds">£310</div></div></div>'
        expect(helper.build_section('section name', view, ['fee'])).to eq(expected)
      end

      context 'when link title and url is also passed' do
        let(:title) { 'TITLE' }
        let(:url) { 'URL' }

        it 'returns the correct html' do
          expected = "<div class=\"summary-section\"><div class=\"grid-row header-row\"><div class=\"column-two-thirds\"><h4 class=\"heading-medium util_mt-0\">section name</h4></div><div class=\"column-one-third\"><a class=\"right\" data-section-name=\"null\" href=\"#{url}\">#{title}</a></div></div><div class=\"grid-row\"><div class=\"column-one-third\">Fee</div><div class=\"column-two-thirds\">£310</div></div></div>"
          expect(helper.build_section('section name', view, ['fee'], title: title, url: url)).to eq(expected)
        end

        it 'returns the correct html with data attribute' do
          expected = "<div class=\"summary-section\"><div class=\"grid-row header-row\"><div class=\"column-two-thirds\"><h4 class=\"heading-medium util_mt-0\">section name</h4></div><div class=\"column-one-third\"><a class=\"right\" data-section-name=\"#{title}\" href=\"#{url}\">#{title}</a></div></div><div class=\"grid-row\"><div class=\"column-one-third\">Fee</div><div class=\"column-two-thirds\">£310</div></div></div>"
          expect(helper.build_section('section name', view, ['fee'], title: title, url: url, section_name: title)).to eq(expected)
        end
      end

      context 'when passed a value starting with `W`' do
        let(:view) { instance_double(Views::Overview::Details, fee: 'WA123456A') }

        it 'returns the correct html' do
          expected = '<div class="summary-section"><div class="grid-row header-row"><div class="column-two-thirds"><h4 class="heading-medium util_mt-0">section name</h4></div></div><div class="grid-row"><div class="column-one-third">Fee</div><div class="column-two-thirds">WA123456A</div></div></div>'
          expect(helper.build_section('section name', view, ['fee'])).to eq(expected)
        end
      end
    end
  end
end
