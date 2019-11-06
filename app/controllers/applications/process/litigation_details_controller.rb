module Applications
  module Process
    class LitigationDetailsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::LitigationDetail.new(application.applicant)
      end

      def create
        @form = Forms::Application::LitigationDetail.new(application.applicant)
        @form.update_attributes(form_params(:litigation_details))

        if @form.save
          redirect_to application_details_path
        else
          render :index
        end
      end

    end
  end
end
