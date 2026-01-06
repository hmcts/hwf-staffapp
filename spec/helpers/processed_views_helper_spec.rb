require 'rails_helper'

RSpec.describe ProcessedViewsHelper do
  describe '#translate_page_name' do
    context 'when page name is blank' do
      it 'returns "Unknown Page"' do
        expect(helper.translate_page_name(nil)).to eq('Unknown Page')
        expect(helper.translate_page_name('')).to eq('Unknown Page')
      end
    end

    context 'when page name contains numeric IDs' do
      it 'strips numeric IDs from the page name' do
        expect(helper.translate_page_name('processed_applications_450')).to eq('Processed Applications')
      end
    end

    context 'when translation exists' do
      before do
        allow(I18n).to receive(:exists?).with('page_titles.home').and_return(true)
        allow(I18n).to receive(:t).with('page_titles.home').and_return('Home')
      end

      it 'returns the translated page title' do
        expect(helper.translate_page_name('home')).to eq('Home')
      end
    end

    context 'when translation does not exist' do
      before do
        allow(I18n).to receive(:exists?).and_return(false)
      end

      it 'returns humanized version of page name' do
        expect(helper.translate_page_name('applications_details')).to eq('Applications Details')
        expect(helper.translate_page_name('personal_informations')).to eq('Personal Informations')
      end
    end
  end

  describe '#format_event_name' do
    let(:event) { instance_double(Ahoy::Event, name: event_name, properties: properties) }

    context 'when event has no properties' do
      let(:event_name) { 'Button Click' }
      let(:properties) { nil }

      it 'returns the event name' do
        expect(helper.format_event_name(event)).to eq('Button Click')
      end
    end

    context 'for Button Click events' do
      let(:event_name) { 'Button Click' }

      context 'with button text' do
        let(:properties) { { 'button_text' => 'Start now' } }

        it 'returns formatted button click text' do
          expect(helper.format_event_name(event)).to eq('"Start now" button click')
        end
      end

      context 'without button text' do
        let(:properties) { {} }

        it 'returns the event name' do
          expect(helper.format_event_name(event)).to eq('Button Click')
        end
      end
    end

    context 'for Link Click events' do
      let(:event_name) { 'Link Click' }

      context 'with link text' do
        let(:properties) { { 'link_text' => 'Continue' } }

        it 'returns formatted link click text' do
          expect(helper.format_event_name(event)).to eq('"Continue" link click')
        end
      end

      context 'without link text' do
        let(:properties) { {} }

        it 'returns the event name' do
          expect(helper.format_event_name(event)).to eq('Link Click')
        end
      end
    end

    context 'for Radio Selection events' do
      let(:event_name) { 'Radio Selection' }

      context 'with radio label' do
        let(:properties) { { 'radio_label' => 'Yes', 'radio_value' => 'true' } }

        it 'returns formatted selection with label' do
          expect(helper.format_event_name(event)).to eq('Selected: "Yes"')
        end
      end

      context 'without label but with value' do
        let(:properties) { { 'radio_value' => 'true' } }

        it 'returns formatted selection with value' do
          expect(helper.format_event_name(event)).to eq('Selected: true')
        end
      end

      context 'without label or value' do
        let(:properties) { {} }

        it 'returns the event name' do
          expect(helper.format_event_name(event)).to eq('Radio Selection')
        end
      end
    end

    context 'for Checkbox Change events' do
      let(:event_name) { 'Checkbox Change' }

      context 'when checked with label' do
        let(:properties) { { 'checkbox_label' => 'I agree', 'checkbox_checked' => true } }

        it 'returns formatted checked text' do
          expect(helper.format_event_name(event)).to eq('Checked: "I agree"')
        end
      end

      context 'when unchecked with label' do
        let(:properties) { { 'checkbox_label' => 'Send emails', 'checkbox_checked' => false } }

        it 'returns formatted unchecked text' do
          expect(helper.format_event_name(event)).to eq('Unchecked: "Send emails"')
        end
      end

      context 'without label' do
        let(:properties) { { 'checkbox_checked' => true } }

        it 'returns the event name' do
          expect(helper.format_event_name(event)).to eq('Checkbox Change')
        end
      end
    end

    context 'for Select Change events' do
      let(:event_name) { 'Select Change' }

      context 'with select text' do
        let(:properties) { { 'select_text' => 'Option 1' } }

        it 'returns formatted selection text' do
          expect(helper.format_event_name(event)).to eq('Selected: "Option 1"')
        end
      end

      context 'without text but with name' do
        let(:properties) { { 'select_name' => 'payment_method' } }

        it 'returns formatted change text' do
          expect(helper.format_event_name(event)).to eq('Changed: payment_method')
        end
      end

      context 'without text or name' do
        let(:properties) { {} }

        it 'returns the event name' do
          expect(helper.format_event_name(event)).to eq('Select Change')
        end
      end
    end

    context 'for Form Submit events' do
      let(:event_name) { 'Form Submit' }
      let(:properties) { { 'page' => 'home' } }

      it 'returns "Form submitted"' do
        expect(helper.format_event_name(event)).to eq('Form submitted')
      end
    end

    context 'for Paper Application Started events' do
      let(:event_name) { 'Paper Application Started' }
      let(:properties) { { 'page' => 'home' } }

      it 'returns friendly message' do
        expect(helper.format_event_name(event)).to eq('Started paper application')
      end
    end

    context 'for Online Application Lookup events' do
      let(:event_name) { 'Online Application Lookup' }
      let(:properties) { { 'page' => 'home' } }

      it 'returns friendly message' do
        expect(helper.format_event_name(event)).to eq('Looked up online application')
      end
    end

    context 'for Application Search events' do
      let(:event_name) { 'Application Search' }
      let(:properties) { { 'page' => 'home' } }

      it 'returns friendly message' do
        expect(helper.format_event_name(event)).to eq('Searched for application')
      end
    end

    context 'for unknown event types' do
      let(:event_name) { 'Unknown Event' }
      let(:properties) { {} }

      it 'returns the event name as-is' do
        expect(helper.format_event_name(event)).to eq('Unknown Event')
      end
    end
  end
end
