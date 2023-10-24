module Applications
  module Process
    class SummaryController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @fee_status = Views::Overview::FeeStatus.new(application)
        @applicant = Views::Overview::Applicant.new(application)
        @details = Views::Overview::Details.new(application)
        @savings = Views::Overview::SavingsAndInvestments.new(application.saving)
        @benefits = Views::Overview::Benefits.new(application)
        @income = Views::Overview::Income.new(application)
      end

      def create
        resolve_only_new_applications
        redirect_to application_confirmation_path(application.id, 'paper')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = I18n.t('error_messages.summary.validation')
        Sentry.capture_message(e.message, extra: { application_id: application.id })

        redirect_to application_summary_path(application)
      end

      private

      def resolve_only_new_applications
        return if application.state != 'created'
        ResolverService.new(application, current_user).complete
      end
    end
  end
end
