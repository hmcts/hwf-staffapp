require 'rails_helper'

RSpec.describe FormObject do

  class FormTestClass < FormObject
    def self.permitted_attributes
      { id: Integer, fee: Integer }
    end

    define_attributes
  end

  params_list = FormTestClass.permitted_attributes.keys

  let(:application) { create :application }
  let(:object_or_hash) { application }
  subject(:form) { FormTestClass.new(object_or_hash) }

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
end
