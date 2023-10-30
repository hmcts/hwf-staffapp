module Applications
  module Process
    class FeeStatusController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::FeeStatus.new(application.detail)
      end

      def create
        app_form_repository = ApplicationFormRepository.new(application, form_params(:details))
        @form = app_form_repository.process(:fee_status)

        if app_form_repository.success?
          redirect_to application_personal_informations_path(application)
        else
          render :index
        end
      end

    end
  end
end
