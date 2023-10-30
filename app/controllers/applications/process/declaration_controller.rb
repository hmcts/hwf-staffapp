module Applications
  module Process
    class DeclarationController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Declaration.new(application.detail)
      end

      def create
        app_form_repository = ApplicationFormRepository.new(application, form_params(:declaration))
        @form = app_form_repository.process(:declaration)

        if app_form_repository.success?
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def go_to_representative_page?
        return false if application.detail.statement_signed_by.blank?
        application.detail.statement_signed_by != 'applicant'
      end

      def path_to_next_page
        if go_to_representative_page?
          application_representative_path(application)
        else
          application_summary_path(application)
        end
      end
    end
  end
end
