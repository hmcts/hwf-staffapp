module Applications
  module Process
    class SummaryController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @applicant = Views::Overview::Applicant.new(application)
        @details = Views::Overview::Details.new(application)
        @savings = Views::Overview::SavingsAndInvestments.new(application.saving)
        @benefits = Views::Overview::Benefits.new(application)
        @income = Views::Overview::Income.new(application)
      end

      def create
        ResolverService.new(application, current_user).complete
        redirect_to application_confirmation_path(application.id)
      rescue ActiveRecord::RecordInvalid => ex
        flash[:alert] = I18n.t('error_messages.summary.validation')
        Raven.capture_exception(ex, application_id: @application.id)

        redirect_to application_summary_path(@application)
      end
    end
  end
end
