module Applications
  module Process
    class IncomesController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if !application.benefits?
          @form = Forms::Application::Income.new(application)
          render :index
        else
          redirect_to application_summary_path(application)
        end
      end

      def create
        @form = Forms::Application::Income.new(application)
        @form.update_attributes(form_params(:income))

        if @form.save
          IncomeCalculationRunner.new(application).run
          redirect_to application_summary_path(application)
        else
          render :index
        end
      end
    end
  end
end
