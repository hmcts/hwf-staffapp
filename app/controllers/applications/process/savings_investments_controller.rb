module Applications
  module Process
    class SavingsInvestmentsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::SavingsInvestment.new(application.saving)
      end

      def create
        @form = Forms::Application::SavingsInvestment.new(application.saving)
        @form.update(form_params(:savings_investments))

        if @form.save
          redirect_to next_page_to_go
        else
          render :index
        end
      end

      private

      def saving_failed
        @band = BandBaseCalculation.new(application)
        @band.remission
        application.saving.update(passed: @band.saving_passed?)
        return false if @band.saving_passed?
        update_application_with_failed_saving
        true
      end

      def update_application_with_failed_saving
        application.update(
          outcome: @band.remission, application_type: 'income',
          amount_to_pay: application.detail.fee,
          income: nil, benefits: nil
        )
      end

      def next_page_to_go
        if ucd_changes_apply?
          saving_outcome_path
        else
          SavingsPassFailService.new(application.saving).calculate!
          application_benefits_path(application)
        end
      end

      def saving_outcome_path
        if saving_failed
          application_declaration_path(application)
        else
          application_benefits_path(application)
        end
      end
    end
  end
end
