module Applications
  module Process
    class PartnerInformationsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Partner.new(application.applicant)
      end

      def create
        @form = Forms::Application::Partner.new(application.applicant)
        @form.update(form_params(:partner))

        if @form.save
          redirect_to application_details_path(application)
        else
          render :index
        end
      end
    end
  end
end
