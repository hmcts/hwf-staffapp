require 'rails_helper'

RSpec.feature 'Business entity management:' do

  include Warden::Test::Helpers

  Warden.test_mode!

  let!(:office) { create(:office, business_entities: [business_entity]) }
  let(:admin) { create(:admin_user, office: office) }
  let(:manager) { create(:manager, office: office) }
  let(:business_entity) { create(:business_entity) }

  before do
    OfficeJurisdiction.where(jurisdiction_id: office.jurisdictions.last.id).delete_all
    login_as admin
  end

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
    context 'when viewing an office' do
      before { visit office_path(office) }

      scenario 'is shown a link to edit business entities' do
        expect(page).to have_content 'Edit the business entities'
      end
    end

    context 'when viewing the business_entity index' do
      before { visit office_business_entities_path(office) }

      scenario 'it displays expected update links' do
        expect(page).to have_xpath('//a', text: 'Update', count: 1)
      end

      scenario 'it displays expected deactivate links' do
        expect(page).to have_xpath('//a', text: 'Deactivate', count: 1)
      end

      scenario 'it displays expected addition link' do
        expect(page).to have_xpath('//a', text: 'Add', count: 5)
      end
    end

    context 'after processing an entity' do
      let(:button_url) { edit_office_business_entity_path(office, business_entity.id) }
      let(:new_description) { business_entity.name }
      let(:new_sop_code) { '987654321' }

      before { visit office_business_entities_path(office) }

      context 'by editing' do
        before do
          find("a[href='#{button_url}']").click
          fill_in 'business_entity_name', with: new_description
          fill_in 'business_entity_sop_code', with: new_sop_code
          click_button 'Update business entity'
          business_entity.reload
        end

        scenario 'the index page reflects the update' do
          expect(page).to have_content new_description
          expect(page).to have_content new_sop_code
        end

        scenario 'original business_entity has been deactivated' do
          expect(business_entity.valid_to).not_to be_nil
        end
      end

      context 'by adding' do
        let(:office_jurisdiction) { office.jurisdictions.last }
        before do
          within(:xpath, "//tr[contains(.,'#{office_jurisdiction.name}')]") do
            click_link 'Add'
          end
          fill_in 'business_entity_name', with: new_description
          fill_in 'business_entity_sop_code', with: new_sop_code
          click_button 'Create business entity'
        end

        scenario 'the index page reflects the update' do
          expect(page).to have_content new_description
          expect(page).to have_content new_sop_code
        end

        scenario 'only 4 jurisdictions can be added now' do
          expect(page).to have_xpath('//a', text: 'Add', count: 4)
        end
      end

      context 'by deleting' do
        before do
          click_link 'Deactivate'
          click_button 'Deactivate'
        end

        scenario 'an additional jurisdictions can be added' do
          expect(page).to have_xpath('//a', text: 'Add', count: 6)
        end

        scenario 'no more jurisdictions can be deactivated' do
          expect(page).to have_no_xpath('//a', text: 'Deactivate')
        end
      end
    end
  end

end
