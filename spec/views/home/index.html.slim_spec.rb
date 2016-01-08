require 'rails_helper'

RSpec.describe "home/index.html.slim", type: :view do

  include Devise::TestHelpers

  let(:user) { create :user }

  let(:application_new?) { false }
  let(:application_index?) { false }
  let(:report_graphs?) { false }

  before do
    allow(view).to receive(:policy).with(:application).and_return(double(new?: application_new?, index?: application_index?))
    allow(view).to receive(:policy).with(:report).and_return(double(graphs?: report_graphs?))

    sign_in user

    render
  end

  subject { rendered }

  describe 'Process application box' do
    context 'when user has permissions to process application' do
      let(:application_new?) { true }

      it 'is rendered' do
        is_expected.to have_text 'Process application'
        is_expected.to have_link 'Start now'
      end
    end

    context 'when user does not have permissions to process application' do
      it 'is not rendered' do
        is_expected.not_to have_text 'Process application'
        is_expected.not_to have_link 'Start now'
      end
    end
  end

  describe 'Waiting applications' do
    context 'when user has permissions to list applications' do
      let(:application_index?) { true }

      it 'are rendered' do
        is_expected.to have_content 'Waiting for evidence'
        is_expected.to have_content 'Waiting for part-payment'
      end
    end
    context 'when user does not have permissions to list applications' do
      it 'are not rendered' do
        is_expected.not_to have_content 'Waiting for evidence'
        is_expected.not_to have_content 'Waiting for part-payment'
      end
    end
  end

  describe 'Processed and deleted applications' do
    context 'when user has permissions to list applications' do
      let(:application_index?) { true }

      it 'are rendered' do
        is_expected.to have_content 'Processed applications'
        is_expected.to have_link 'View all', href: processed_applications_path
        is_expected.to have_content 'Deleted applications'
        is_expected.to have_link 'View all', href: deleted_applications_path
      end
    end

    context 'when user does not have permissions to list applications' do
      it 'are not rendered' do
        is_expected.not_to have_content 'Processed applications'
        is_expected.not_to have_link 'View all', href: processed_applications_path
        is_expected.not_to have_content 'Deleted applications'
        is_expected.not_to have_link 'View all', href: deleted_applications_path
      end
    end
  end

  describe 'Usage graphs' do
    context 'when user has permissions to see the graphs' do
      let(:report_graphs?) { true }

      it 'are rendered' do
        is_expected.to have_xpath('//h2', text: 'Total')
      end
    end

    context 'when user does not have permissions to see the graphs' do
      it 'are not rendered' do
        is_expected.not_to have_xpath('//h2', text: 'Total')
      end
    end
  end
end
