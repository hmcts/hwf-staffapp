require 'rails_helper'

describe SpotcheckSelector do
  subject(:spotcheck_selector) { described_class.new(application) }

  describe '#decide!' do
    subject do
      spotcheck_selector.decide!

      application.reload
      application.spotcheck?
    end

    context 'for a benefit application' do
      let(:application) { create :application }

      before do
        create_list :application, 9
      end

      it 'never selects the application for spotcheck' do
        is_expected.to be false
      end
    end

    context 'for a non-benefit application' do
      let(:application) { create :application, :no_benefits }

      context 'for a non-refund application' do
        context 'when the application is the 10th (10% gets checked)' do
          before do
            create_list :application, 9, :no_benefits
            create_list :application, 5
          end

          it 'sets the spotcheck flag on the application to true' do
            is_expected.to be true
          end
        end

        context 'when the application is not the 10th' do
          before do
            create_list :application, 4, :no_benefits
            create_list :application, 5
          end

          it 'sets the spotcheck flag on the application to false' do
            is_expected.to be false
          end
        end
      end

      context 'for a refund application' do
        let(:application) { create :application, :refund, :no_benefits }

        context 'when the application is the 2nd (50% gets checked)' do
          before do
            create_list :application, 3, :refund, :no_benefits
            create_list :application, 5
          end

          it 'sets the spotcheck flag on the application to true' do
            is_expected.to be true
          end
        end

        context 'when the application is not the 2nd' do
          before do
            create_list :application, 2, :refund, :no_benefits
            create_list :application, 3
          end

          it 'sets the spotcheck flag on the application to true' do
            is_expected.to be false
          end
        end
      end
    end
  end
end
