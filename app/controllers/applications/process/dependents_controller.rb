module Applications
  module Process
    class DependentsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if application.benefits?
          redirect_to application_summary_path(application)
        else
          @form = Forms::Application::Dependent.new(application)
          render :index
        end
      end

      def create
        @form = Forms::Application::Dependent.new(application)
        @form.update(form_params(:dependent))

        if @form.save
          IncomeCalculationRunner.new(application).run
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def path_to_next_page
        if ucd_changes_apply?
          application_income_kind_applicants_path(application)
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
    end
  end
end
