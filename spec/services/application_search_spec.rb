require 'rails_helper'

RSpec.describe ApplicationSearch do
  subject(:service) { described_class.new(reference, user) }

  include Rails.application.routes.url_helpers
  let(:reference) { nil }
  let(:user) { create :staff }

  it { is_expected.to respond_to :error_message }

  describe '#completed' do
    subject(:service_completed) { service.completed }

    let(:existing_reference) { 'XYZ-123-ABC' }
    let(:wrong_reference) { 'XYZ-WRO-NG' }

    context 'when there is an application with the given reference' do
      let(:reference) { existing_reference }
      before { application }

      context 'when the application has been processed in the same office' do
        context 'when waiting for evidence' do
          let(:evidence_check) { create(:evidence_check) }
          let(:application) { create(:application, :waiting_for_evidence_state, reference: reference, office: user.office, evidence_check: evidence_check) }

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
        let(:office) { create :office }
        let(:application) { create(:application, :processed_state, reference: reference, office: office) }

        it { expect(service_completed).to be nil }
        it {}
      end

      context 'when the application has not yet been completed' do
        let(:application) { create(:application, :uncompleted, reference: reference) }

        it { expect(service_completed).to be nil }
      end
    end

    context 'when there is no application with the given reference' do
      let(:reference) { wrong_reference }

      it { is_expected.to be nil }

      it 'sets the correct error message' do
        service_completed
        expect(service.error_message).to eq "No results found"
      end
    end

    context 'when the search is empty' do
      let(:reference) { '' }

      it { is_expected.to be nil }

      it 'sets the correct error message' do
        service_completed
        expect(service.error_message).to eq "Enter a search term"
      end
    end

  end

  describe '#paginate_search_results' do
    let(:paginated_result) { instance_double(Application::ActiveRecord_Relation, 'paginated') }

    let(:reference) { 'XYZ-123-ABC' }
    let(:application) { create(:application, :processed_state, reference: reference, office: user.office) }
    let(:pagination_params) { { 'sort_to': 'DESC', 'sort_by': 'last_name', 'page': 1 } }

    before do
      application
      service.completed
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
