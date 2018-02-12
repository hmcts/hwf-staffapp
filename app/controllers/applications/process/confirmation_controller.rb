module Applications
  module Process
    class ConfirmationController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if application.evidence_check.present?
          redirect_to(evidence_check_path(application.evidence_check.id))
        else
          @confirm = Views::Confirmation::Result.new(application)
          @form = Forms::Application::DecisionOverride.new(application)
        end
      end
    end
  end
end
