require 'rails_helper'

module Forms
  class FormTestClass < FormObject
    def self.permitted_attributes
      { id: :integer, fee: :integer }
    end

    define_attributes
  end
end

RSpec.describe FormObject do
  subject(:form) { Forms::FormTestClass.new(object_or_hash) }

  describe '.permitted_attributes' do
    it { expect(described_class.permitted_attributes).to eq({}) }
  end

  params_list = Forms::FormTestClass.permitted_attributes.keys

  let(:application) { create(:detail) }
  let(:object_or_hash) { application }

  describe '#initialize' do
    describe 'when an ActiveRecord object is passed in' do
      params_list.each do |attr_name|
        it "assigns #{attr_name}" do
          expect(form.send(attr_name)).to eq application.send(attr_name)
        end
      end
    end

    describe 'when a Hash is passed in' do
      let(:hash) { { id: 1, fee: 2 } }
      let(:object_or_hash) { hash }

      params_list.each do |attr_name|
        it "assigns #{attr_name}" do
          expect(form.send(attr_name)).to eq hash[attr_name]
        end
      end
    end
  end

  describe '#update' do
    let(:params) { { fee: 10 } }
    before do
      form.update(params)
    end

    it 'updates the attributes on the form' do
      expect(form.fee).to eql(params[:fee])
    end
  end

  describe '#save' do
    subject(:form_save) { form.save }

    context 'when the form is valid' do
      let(:valid) { true }

      it { expect { form_save }.to raise_error NotImplementedError }
    end

    # rubocop:disable RSpec/SubjectStub
    context 'when the form is not valid' do
      before do
        allow(form).to receive(:valid?).and_return(valid)
      end

      let(:valid) { false }

      it { expect { form_save }.not_to raise_error }

      it { is_expected.to be false }
    end
    # rubocop:enable RSpec/SubjectStub
  end

  describe '#i18n_scope' do
    it 'returns scope for form field attributes' do
      expect(form.i18n_scope).to be :'activemodel.attributes.forms/form_test_class'
    end
  end
end
