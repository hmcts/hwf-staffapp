require 'rails_helper'

RSpec.describe ApplicationBuilder do

  let(:user) { create :user }
  let(:application_builder) { described_class.new(user) }

  describe '#create_application' do
    let(:application_params) do
      {
        jurisdiction_id: user.jurisdiction_id,
        office_id: user.office_id,
        user_id: user.id
      }
    end

    it 'creates and populates the Application' do
      expect(Application).to receive(:create).with(application_params)
      application_builder.create_application
    end
  end

  describe '#create_reference' do
    before { application_builder.create_application }

    let(:reference_params) do
      {
        application_id: application_builder.application.id
      }
    end

    it 'creates and populates Reference of the Application' do
      expect(Reference).to receive(:create).with(reference_params)
      application_builder.create_reference
    end
  end
end
