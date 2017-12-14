module Applications
  module Process
    class BenefitsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @state = DwpMonitor.new.state
        if application.saving.passed?
          @form = Forms::Application::Benefit.new(application)
          render :index
        else
          redirect_to application_summary_path(application)
        end
      end

      def create
        @form = Forms::Application::Benefit.new(application)
        @form.update_attributes(form_params(:benefits))

        if @form.save
          benefit_check_and_redirect(@form.benefits)
        else
          render :index
        end
      end
    end
  end
end
