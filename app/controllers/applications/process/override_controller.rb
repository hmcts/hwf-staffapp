module Applications
  module Process
    class OverrideController < Applications::ProcessController
      before_action :authorize_application_update

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
    end

  end
end
