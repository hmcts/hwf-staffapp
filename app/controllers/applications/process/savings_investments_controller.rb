module Applications
  module Process
    class SavingsInvestmentsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::SavingsInvestment.new(application.saving)
      end

      def create
        @form = Forms::Application::SavingsInvestment.new(application.saving)
        @form.update_attributes(form_params(:savings_investments))

        if @form.save
          SavingsPassFailService.new(application.saving).calculate!
          redirect_to application_benefits_path(application)
        else
          render :index
        end
      end

    end
  end
end
