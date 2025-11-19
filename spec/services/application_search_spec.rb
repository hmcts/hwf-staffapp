require 'rails_helper'

RSpec.describe ApplicationSearch do
  subject(:service) { described_class.new(reference, user) }

  include Rails.application.routes.url_helpers

  let(:reference) { nil }
  let(:user) { create(:staff) }

  it { is_expected.to respond_to :error_message }

  describe '#call' do
    subject(:service_completed) { service.call }

    let(:existing_reference) { 'HWF-123-ABC' }
    let(:wrong_reference) { 'PA18-WRO-NG' }

    context 'when there is an application with the given reference' do
      let(:reference) { existing_reference }
      before { application }

      context 'when the application has been processed in the same office' do
        context 'when waiting for evidence' do
          let(:evidence_check) { application.evidence_check }
          let(:application) { create(:application, :waiting_for_evidence_state, reference: reference, office: user.office) }

          it 'returns the application' do
            expect(service_completed).to eq([application])
          end
        end

        context 'when waiting for part payment' do
          let(:part_payment) { create(:part_payment) }
          let(:application) { create(:application, :waiting_for_part_payment_state, reference: reference, office: user.office, part_payment: part_payment) }

          it 'returns the part payment url' do
            is_expected.to eq([application])
          end
        end

        context 'when processed' do
          let(:application) { create(:application, :processed_state, reference: reference, office: user.office) }

          it 'returns the processed application url' do
            is_expected.to eq([application])
          end
        end

        context 'when deleted' do
          let(:application) { create(:application, :deleted_state, reference: reference, office: user.office) }

          it 'returns the deleted application' do
            is_expected.to eq([application])
          end
        end
      end

      context 'when the application has not been processed in the same office' do
        context 'staff user' do
          let(:office) { create(:office, name: 'ACDC Office') }
          let(:application) { create(:application, :processed_state, reference: reference, office: office) }

          it { expect(service_completed).to be_nil }

          it 'return error about different office processing this application' do
            service_completed
            expect(service.error_message).to eq("This application has been processed by ACDC Office")
          end
        end

        context 'admin user' do
          let(:user) { create(:admin_user) }
          let(:office) { create(:office, name: 'ACDC Office') }
          let(:application) { create(:application, :processed_state, reference: reference, office: office) }

          it { expect(service_completed).to eq([application]) }

          it 'return error about different office processing this application' do
            service_completed
            expect(service.error_message).not_to eq("This application has been processed by ACDC Office")
          end
        end
      end

      context 'when the application has not yet been completed' do
        context 'staff user' do
          let(:application) { create(:application, :uncompleted, reference: reference, office: user.office) }

          it { expect(service_completed).to be_nil }
        end

        context 'admin user' do
          let(:user) { create(:admin_user) }
          let(:application) { create(:application, :uncompleted, reference: reference) }

          it 'returns the uncompleted application for admin' do
            expect(service_completed).to eq([application])
          end
        end
      end
    end

    context 'when there is no application with the given reference' do
      let(:reference) { wrong_reference }

      it { is_expected.to be_nil }

      it 'sets the correct error message' do
        service_completed
        expect(service.error_message).to eq "No results found"
      end
    end

    context 'when the search is empty' do
      let(:reference) { '' }

      it { is_expected.to be_nil }

      it 'sets the correct error message' do
        service_completed
        expect(service.error_message).to eq "Enter a search term"
      end
    end

    context 'when searching by name' do
      let(:reference) { 'Smith' }
      let(:other_office) { create(:office, name: 'Other Office') }

      context 'staff user' do
        let(:application_same_office) { create(:application, :processed_state, office: user.office) }
        let(:application_other_office) { create(:application, :processed_state, office: other_office) }

        before do
          create(:applicant, first_name: 'John', last_name: 'Smith', application: application_same_office)
          create(:applicant, first_name: 'Jane', last_name: 'Smith', application: application_other_office)
        end

        it 'only returns applications from the same office' do
          expect(service_completed).to eq([application_same_office])
        end
      end

      context 'admin user' do
        let(:user) { create(:admin_user) }
        let(:application_office_1) { create(:application, :processed_state, office: user.office) }
        let(:application_office_2) { create(:application, :processed_state, office: other_office) }

        before do
          create(:applicant, first_name: 'John', last_name: 'Smith', application: application_office_1)
          create(:applicant, first_name: 'Jane', last_name: 'Smith', application: application_office_2)
        end

        it 'returns applications from all offices' do
          expect(service_completed).to match_array([application_office_1, application_office_2])
        end
      end
    end

    context 'when searching by NI number' do
      let(:reference) { 'JR054008D' }
      let(:other_office) { create(:office, name: 'Other Office') }

      context 'staff user' do
        let(:application_same_office) { create(:application, :processed_state, office: user.office) }
        let(:application_other_office) { create(:application, :processed_state, office: other_office) }

        before do
          create(:applicant, ni_number: reference, application: application_same_office)
          create(:applicant, ni_number: 'SN123456C', application: application_other_office)
        end

        it 'only returns applications from the same office' do
          expect(service_completed).to eq([application_same_office])
        end
      end

      context 'admin user' do
        let(:user) { create(:admin_user) }
        let(:application_office_1) { create(:application, :processed_state, office: user.office) }
        let(:application_office_2) { create(:application, :processed_state, office: other_office) }

        before do
          create(:applicant, ni_number: reference, application: application_office_1)
          create(:applicant, ni_number: reference, application: application_office_2)
        end

        it 'returns applications from all offices with matching NI number' do
          expect(service_completed).to match_array([application_office_1, application_office_2])
        end
      end
    end

  end

  describe '#paginate_search_results' do
    let(:ar_class) { Application.const_get(:ActiveRecord_Relation) }
    let(:paginated_result) { instance_double(ar_class, 'paginated') }

    let(:reference) { 'HWF-123-ABC' }
    let(:application) { create(:application, :processed_state, reference: reference, office: user.office) }
    let(:pagination_params) { { sort_to: 'DESC', sort_by: 'last_name', page: 1 } }

    before do
      application
      service.call
    end

    it 'paginate the results' do
      allow(paginated_result).to receive(:reorder)

      service.paginate_search_results(pagination_params)
      expect(service.results).to eq([application])
    end

    context 'sort' do
      let(:sort_string) { 'applicants.last_name DESC, applications.created_at DESC, applicants.first_name ASC' }
      let(:search_service) { service }

      before do
        allow(search_service).to receive(:paginate_results).and_return paginated_result
        allow(paginated_result).to receive(:reorder).with(sort_string).and_return 'sorted results'
      end

      it 'sorts paginated results' do
        results = service.paginate_search_results(pagination_params)
        expect(results).to eql('sorted results')
      end

    end
  end
end
