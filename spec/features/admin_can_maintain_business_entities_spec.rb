require 'rails_helper'

RSpec.feature 'Business entity management:', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:office) { create :office }
  let(:admin) { create :admin_user, office: office }
  let(:manager) { create :manager, office: office }
  let(:business_entity) { office.business_entities.first }

  before { OfficeJurisdiction.delete_all(jurisdiction_id: office.jurisdictions.last.id) }

  context 'as a user who cannot access' do
    before { login_as manager }

    context 'when editing an office' do
      before { visit edit_office_path(office) }

      scenario 'is shown a link to edit business entities' do
        expect(page).to have_no_content 'Edit the business entities'
      end
    end
  end

  context 'as a user with access' do
    before { login_as admin }

    context 'when viewing an office' do
      before { visit office_path(office) }

      scenario 'is shown a link to edit business entities' do
        expect(page).to have_content 'Edit the business entities'
      end
    end

    context 'when viewing the business_entity index' do
      before { visit office_business_entities_path(office) }

      scenario 'it displays expected update links' do
        expect(page).to have_xpath('//a', text: 'Update', count: 2)
      end

      scenario 'it displays expected deactivate links' do
        expect(page).to have_xpath('//a', text: 'Deactivate', count: 1)
      end

      scenario 'it displays expected addition link' do
        expect(page).to have_xpath('//a', text: 'Add', count: 1)
      end
    end

    context 'after processing an entity' do
      let(:button_url) { edit_office_business_entity_path(office, business_entity.id) }
      let(:new_description) { 'New description' }
      let(:new_code) { 'XY987' }

      before { visit office_business_entities_path(office) }

      context 'by editing' do
        before do
          find("a[href='#{button_url}']").click
          fill_in 'business_entity_name', with: new_description
          fill_in 'business_entity_code', with: new_code
          click_button 'Update business entity'
          business_entity.reload
        end

        scenario 'the index page reflects the update' do
          expect(page).to have_content new_description
          expect(page).to have_content new_code
        end

        scenario 'original business_entity has been deactivated' do
          expect(business_entity.valid_to).not_to eq nil
        end
      end

      context 'by adding' do
        before do
          click_link 'Add'
          fill_in 'business_entity_name', with: new_description
          fill_in 'business_entity_code', with: new_code
          click_button 'Create business entity'
        end

        scenario 'the index page reflects the update' do
          expect(page).to have_content new_description
          expect(page).to have_content new_code
        end

        scenario 'no more jurisdictions can be added' do
          expect(page).to have_no_xpath('//a', text: 'Add')
        end
      end

      context 'by deleting' do
        before do
          click_link 'Deactivate'
          click_button 'Deactivate'
        end

        scenario 'an additional jurisdictions can be added' do
          expect(page).to have_xpath('//a', text: 'Add', count: 2)
        end

        scenario 'no more jurisdictions can be deactivated' do
          expect(page).to have_no_xpath('//a', text: 'Deactivate')
        end
      end
    end
  end
end
