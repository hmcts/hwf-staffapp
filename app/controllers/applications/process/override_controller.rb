module Applications
  module Process
    class OverrideController < Applications::ProcessController
      before_action :authorize_application_update
      skip_before_action :check_completed_redirect

      def update
        @form = Forms::Application::DecisionOverride.new(decision_override)

        @form.update_attributes(build_override_params)

        if @form.valid? && OverrideDecisionService.new(application, @form).set!
          redirect_to(application_confirmation_path(application))
        else
          @confirm = Views::Confirmation::Result.new(application)
          render 'applications/process/confirmation/index'
        end
      end

      private

      def build_override_params
        form_params(:decision_override).merge(created_by_id: current_user.id)
      end

      def decision_override
        @decision_override ||= DecisionOverride.find_or_initialize_by(application: application)
      end
    end
  end
end
