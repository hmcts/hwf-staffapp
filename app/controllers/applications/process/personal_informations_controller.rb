module Applications
  module Process
    class PersonalInformationsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Applicant.new(application.applicant)
      end

      def create
        @form = Forms::Application::Applicant.new(application.applicant)
        @form.update_attributes(form_params(:applicant))

        if @form.save
          redirect_to application_details_path
        else
          render :index
        end
      end
    end
  end
end
