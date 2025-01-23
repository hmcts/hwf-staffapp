module Applications
  module Process
    class BenefitsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @dwp_state = dwp_checker_state
        if ucd_changes_apply? || application.saving.passed?
          @form = Forms::Application::Benefit.new(application)
          render :index
        else
          redirect_to application_summary_path(application)
        end
      end

      def create
        @form = Forms::Application::Benefit.new(application)
        @form.update(form_params(:benefits))

        if @form.save
          benefit_check_and_redirect(@form.benefits)
        else
          render :index
        end
      end

      private

      def benefit_check_runner
        @benefit_check_runner ||= BenefitCheckRunner.new(application)
      end

      def benefit_check_and_redirect(benefits)
        if benefits
          benefit_check_runner.run
          determine_override
        else
          reset_benefit_override
          redirect_to application_dependents_path(application)
        end
      end

      def determine_override
        if application.failed_because_dwp_error?
          flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
          redirect_to root_url
        elsif benefit_check_runner.can_override?
          redirect_to application_benefit_override_paper_evidence_path(application)
        else
          redirect_to application_declaration_path(application)
        end
      end

      def reset_benefit_override
        return unless application.benefit_override
        application.benefit_override.destroy
      end
    end
  end
end
