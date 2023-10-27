module Applications
  module Process
    class DeclarationController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Declaration.new(application.detail)
      end

      def create
        # binding.pry
        app_form_repository = ApplicationFormRepository.new(application, form_params(:declaration))
        @form = app_form_repository.process(:declaration)

        if app_form_repository.success?
          redirect_to application_summary_path(application)
        else
          render :index
        end
      end

    end
  end
end
