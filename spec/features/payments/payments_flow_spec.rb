# coding: utf-8
require 'rails_helper'

RSpec.feature 'Payments flow', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user }
  let(:application) { create :application_part_remission, user: user }
  let(:payment) { create :payment, application: application }

  before { login_as user }

  context 'when on the payment flow initial page' do
    before { visit payment_path(id: payment.id) }

    headings = ['Waiting for payment',
                'Process payment',
                'Processing details',
                'Personal details',
                'Application details',
                'Result']

    headings.each do |heading_title|
      it "has a heading titled #{heading_title}" do
        expect(page).to have_content heading_title
      end
    end
  end
end
