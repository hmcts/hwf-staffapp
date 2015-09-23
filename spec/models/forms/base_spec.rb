require 'rails_helper'

RSpec.describe Forms::Base do

  class Forms::TestClass < Forms::Base
    def self.permitted_attributes
      { id: Integer, fee: Integer }
    end

    define_attributes
  end
  params_list = Forms::TestClass.permitted_attributes.keys

  describe 'when Application object is passed in' do
    let(:application) { create :application }
    let(:form) { Forms::TestClass.new(application) }

    params_list.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq application.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { { id: 1, fee: 2 } }
    let(:form) { Forms::TestClass.new(hash) }

    params_list.each do |attr_name|
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name]
      end
    end
  end
end
