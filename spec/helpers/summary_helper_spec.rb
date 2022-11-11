require 'rails_helper'

RSpec.describe SummaryHelper do

  let(:fee_label) { 'Fee' }

  before do
    i18n_key = 'activemodel.attributes.r_spec/mocks/instance_verifying_double.'
    i18n_fee = "#{i18n_key}fee"
    i18n_name = "#{i18n_key}form_name"
    i18n_date = "#{i18n_key}date_received"
    i18n_correct = "#{i18n_key}correct"
    i18n_income = "#{i18n_key}income"
    i18n_reason = "#{i18n_key}incorrect_reason_category"
    allow(I18n).to receive(:t).with(i18n_fee).and_return('Fee')
    allow(I18n).to receive(:t).with(i18n_name).and_return('Form name')
    allow(I18n).to receive(:t).with(i18n_date).and_return('Date received')
    allow(I18n).to receive(:t).with(i18n_correct).and_return('Correct')
    allow(I18n).to receive(:t).with(i18n_income).and_return('Income')
    allow(I18n).to receive(:t).with(i18n_reason).and_return('Reason')
  end

  it { expect(helper).to be_a described_class }

  describe 'build_section_with_defaults' do
    let(:view) { instance_double(Views::Overview::Details, fee: '£310', all_fields: ['fee']) }

    context 'when called with minimal data' do
      it 'returns the correct html' do
        expected = '<h2 class="govuk-heading-m">section name</h2><dl class="govuk-summary-list"><div class="govuk-summary-list__row"><dt class="govuk-summary-list__key">Fee</dt><dd class="govuk-summary-list__value">£310</dd></div></dl>'
        expect(helper.build_section_with_defaults('section name', view)).to eq(expected)
      end
    end
  end

  describe '#build_section' do

    context 'handles nil data fields' do
      let(:view) { instance_double(Views::Overview::Details, fee: '£310', form_name: '', date_received: nil) }

      context 'when requested fields all contain nil data' do
        it 'returns nothing' do
          expect(helper.build_section('section name', view, ['form_name', 'date_received'])).to be_nil
        end
      end

      context 'when requested fields contain some data' do
        it 'returns only the populated field' do
          expected = '<h2 class="govuk-heading-m">section name</h2><dl class="govuk-summary-list"><div class="govuk-summary-list__row"><dt class="govuk-summary-list__key">Fee</dt><dd class="govuk-summary-list__value">£310</dd></div></dl>'
          expect(helper.build_section('section name', view, ['fee', 'form_name', 'date_received'])).to eq(expected)
        end
      end
    end

    context 'when passed a name and an overview object' do
      let(:view) { instance_double(Views::Overview::Details, fee: '£310') }

      it 'returns the correct html' do
        expected = '<h2 class="govuk-heading-m">section name</h2><dl class="govuk-summary-list"><div class="govuk-summary-list__row"><dt class="govuk-summary-list__key">Fee</dt><dd class="govuk-summary-list__value">£310</dd></div></dl>'
        expect(helper.build_section('section name', view, ['fee'])).to eq(expected)
      end

      context 'when link title and url is also passed' do
        let(:title) { 'TITLE' }
        let(:url) { 'URL' }

        it 'returns the correct html' do
          expected = "<h2 class=\"govuk-heading-m\">section name</h2><dl class=\"govuk-summary-list\"><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Fee</dt><dd class=\"govuk-summary-list__value\">£310</dd><dd class=\"govuk-summary-list__actions\"><a class=\"govuk-link\" href=\"#{url}\">Change<span class=\"govuk-visually-hidden\">Fee</span></a></dd></div></dl>"
          expect(helper.build_section('section name', view, ['fee'], title: title, url: url)).to eq(expected)
        end

        it 'returns the correct html with data attribute' do
          expected = "<h2 class=\"govuk-heading-m\">section name</h2><dl class=\"govuk-summary-list\"><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Fee</dt><dd class=\"govuk-summary-list__value\">£310</dd><dd class=\"govuk-summary-list__actions\"><a class=\"govuk-link\" data-section-name=\"#{title}\" href=\"#{url}\">Change<span class=\"govuk-visually-hidden\">Fee</span></a></dd></div></dl>"
          expect(helper.build_section('section name', view, ['fee'], title: title, url: url, section_name: title)).to eq(expected)
        end
      end

      context 'when passed a value starting with `W`' do
        let(:view) { instance_double(Views::Overview::Details, fee: 'WA123456A') }

        it 'returns the correct html' do
          expected = '<h2 class="govuk-heading-m">section name</h2><dl class="govuk-summary-list"><div class="govuk-summary-list__row"><dt class="govuk-summary-list__key">Fee</dt><dd class="govuk-summary-list__value">WA123456A</dd></div></dl>'
          expect(helper.build_section('section name', view, ['fee'])).to eq(expected)
        end
      end
    end
  end

  describe 'build_section_with_custom_links' do
    let(:view) { instance_double(Views::Evidence, correct: 'Yes', income: '£2990') }
    let(:url1) { accuracy_evidence_path(id: 234) }
    let(:url2) { income_evidence_path(id: 234) }
    let(:row1) { { key: 'correct', link_attributes: { url: url1 } } }
    let(:row2) { { key: 'income', link_attributes: { url: url2 } } }

    context 'when called with list of attributes' do
      it 'returns the correct html' do
        expected = "<dl class=\"govuk-summary-list\"><h2 class=\"govuk-heading-m\">Evidence</h2><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Correct</dt><dd class=\"govuk-summary-list__value\">Yes</dd><dd class=\"govuk-summary-list__actions\"><a class=\"govuk-link\" href=\"#{url1}\">Change<span class=\"govuk-visually-hidden\">Correct</span></a></dd></div>"
        expected += "<div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Income</dt><dd class=\"govuk-summary-list__value\">£2990</dd><dd class=\"govuk-summary-list__actions\"><a class=\"govuk-link\" href=\"#{url2}\">Change<span class=\"govuk-visually-hidden\">Income</span></a></dd></div></dl>"
        expect(helper.build_section_with_custom_links('Evidence', view, [row1, row2])).to eq(expected)
      end
    end

    describe 'Plural key' do
      let(:row1) { { key: 'incorrect_reason_category', link_attributes: { url: url1 } } }

      context 'incorrect reason category plural header' do
        let(:view) { instance_double(Views::Evidence, incorrect_reason_category: 'test1, test2') }
        it 'when there are multiple values' do
          expected = "<dl class=\"govuk-summary-list\"><h2 class=\"govuk-heading-m\">Evidence</h2><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Reasons</dt><dd class=\"govuk-summary-list__value\">test1, test2</dd>"
          expected += "<dd class=\"govuk-summary-list__actions\"><a class=\"govuk-link\" href=\"#{url1}\">Change<span class=\"govuk-visually-hidden\">Reasons</span></a></dd></div></dl>"
          expect(helper.build_section_with_custom_links('Evidence', view, [row1])).to eq(expected)
        end
      end

      context 'incorrect reason category singular header' do
        let(:view) { instance_double(Views::Evidence, incorrect_reason_category: 'test1') }
        it 'when there is one value' do
          expected = "<dl class=\"govuk-summary-list\"><h2 class=\"govuk-heading-m\">Evidence</h2><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Reason</dt><dd class=\"govuk-summary-list__value\">test1</dd>"
          expected += "<dd class=\"govuk-summary-list__actions\"><a class=\"govuk-link\" href=\"#{url1}\">Change<span class=\"govuk-visually-hidden\">Reason</span></a></dd></div></dl>"
          expect(helper.build_section_with_custom_links('Evidence', view, [row1])).to eq(expected)
        end
      end

    end

    context 'when called with missing some attributes' do
      it 'empty array' do
        expect(helper.build_section_with_custom_links('Evidence', view, [])).to be_nil
      end

      it 'missing url' do
        expected = "<dl class=\"govuk-summary-list\"><h2 class=\"govuk-heading-m\">Evidence</h2><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Correct</dt><dd class=\"govuk-summary-list__value\">Yes</dd></div></dl>"
        expect(helper.build_section_with_custom_links('Evidence', view, [{ key: 'correct', link_attributes: {} }])).to eq(expected)
      end

      it 'missing link_attributes' do
        expected = "<dl class=\"govuk-summary-list\"><h2 class=\"govuk-heading-m\">Evidence</h2><div class=\"govuk-summary-list__row\"><dt class=\"govuk-summary-list__key\">Correct</dt><dd class=\"govuk-summary-list__value\">Yes</dd></div></dl>"
        expect(helper.build_section_with_custom_links('Evidence', view, [{ key: 'correct' }])).to eq(expected)
      end
    end
  end
end
