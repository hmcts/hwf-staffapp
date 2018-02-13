module Applications
  module Process
    class DetailsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Detail.new(application.detail)
        @jurisdictions = user_jurisdictions
      end

      def create
        app_form_repository = ApplicationFormRepository.new(application, form_params(:details))
        @form = app_form_repository.process(:details)

        if app_form_repository.success?
          redirect_to app_form_repository.redirect_url
        else
          @jurisdictions = user_jurisdictions
          render :index
        end
      end

      private

      def user_jurisdictions
        current_user.office.jurisdictions
      end
    end
  end
end
