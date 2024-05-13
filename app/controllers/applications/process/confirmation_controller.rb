module Applications
  module Process
    class ConfirmationController < Applications::ProcessController
      before_action :authorize_application_update
      skip_before_action :check_completed_redirect
      before_action :set_cache_headers
      after_action :clear_path

      def index
        if application.evidence_check.present?
          redirect_to hmrc_or_paper_path
        else
          @confirm = Views::Confirmation::Result.new(application)
          @form = Forms::Application::DecisionOverride.new(application)
        end
      end

      private

      def hmrc_or_paper_path
        evidence_id = application.evidence_check.id
        if application.evidence_check.income_check_type == 'hmrc' && not_average_income
          new_evidence_check_hmrc_path(evidence_id)
        else
          evidence_check_path(evidence_id)
        end
      end

      def not_average_income
        application.income_period != 'average'
      end
    end
  end
end
