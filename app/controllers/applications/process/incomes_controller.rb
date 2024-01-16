module Applications
  module Process
    class IncomesController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if application.benefits?
          redirect_to application_summary_path(application)
        else
          @form = Forms::Application::Income.new(application)
          render :index
        end
      end

      def create
        @form = Forms::Application::Income.new(application)
        @form.update(form_params(:income))

        if @form.save
          income_calculation
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def path_to_next_page
        if ucd_changes_apply?
          application_declaration_path(application)
        else
          application_summary_path(application)
        end
      end

      def received_and_refund_data
        detail = application.detail
        { date_received: detail.date_received, date_fee_paid: detail.date_fee_paid, refund: detail.refund }
      end

      def ucd_changes_apply?
        FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == application.detail.calculation_scheme
      end

      def income_calculation
        if ucd_changes_apply?
          band_calculation
        else
          IncomeCalculationRunner.new(application).run
        end
      end

      def band_calculation
        band = BandBaseCalculation.new(application)

        application.update(outcome: band.remission, application_type: 'income', amount_to_pay: band.amount_to_pay,
                           income_max_threshold_exceeded: band.income_failed?)
        application.saving.update(passed: band.saving_passed?)
      end

    end
  end
end
