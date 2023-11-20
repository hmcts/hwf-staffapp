module Applications
  module Process
    class PersonalInformationsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Applicant.new(application.applicant)
      end

      def create
        @form = Forms::Application::Applicant.new(application.applicant)
        @form.update(form_params(:applicant))

        if @form.save
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def path_to_next_page
        if application.applicant.married? && ucd_changes_applies?
          application_partner_informations_path(application)
        else
          application_details_path(application)
        end
      end

      def ucd_changes_applies?
        FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == application.detail.calculation_scheme
      end
    end
  end
end
