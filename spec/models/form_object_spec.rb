require 'rails_helper'

RSpec.describe FormObject do

  describe '.permitted_attributes' do
    it { expect(described_class.permitted_attributes).to eq({}) }
  end

  module Forms
    class FormTestClass < FormObject
      def self.permitted_attributes
        { id: Integer, fee: Integer }
      end

      define_attributes
    end
  end

  params_list = Forms::FormTestClass.permitted_attributes.keys

  let(:application) { create :detail }
  let(:object_or_hash) { application }
  subject(:form) { Forms::FormTestClass.new(object_or_hash) }

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

  describe '#update_attributes' do
    let(:params) { { fee: 10 } }
    before do
      form.update_attributes(params)
    end

    it 'updates the attributes on the form' do
      expect(form.fee).to eql(params[:fee])
    end
  end

  describe '#save' do
    before do
      allow(form).to receive(:valid?).and_return(valid)
      allow(form).to receive(:persist!)
    end

    subject { form.save }

    context 'when the form is valid' do
      let(:valid) { true }

      it 'method #persist! is called' do
        subject

        expect(form).to have_received(:persist!)
      end

      it { is_expected.to be true }
    end

    context 'when the form is not valid' do
      let(:valid) { false }

      it 'does not call #persist!' do
        subject

        expect(form).not_to have_received(:persist!)
      end

      it { is_expected.to be false }
    end
  end

  describe '#i18n_scope' do
    it 'returns scope for form field attributes' do
      expect(form.i18n_scope).to eql(:'activemodel.attributes.forms/form_test_class')
    end
  end
end
