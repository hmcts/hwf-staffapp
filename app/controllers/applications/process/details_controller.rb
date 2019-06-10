module Applications
  module Process
    class DetailsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::Detail.new(application.detail)
        @jurisdictions = user_jurisdictions
      end

      def create
        app_form_repository = ApplicationFormRepository.new(application, form_params(:details))
        @form = app_form_repository.process(:details)

        if app_form_repository.success?
          reset_fee_manager_approval_fields
          redirect_to DetailsRouter.new(application).approval_or_continue
        else
          @jurisdictions = user_jurisdictions
          render :index
        end
      end

      def approve
        @form = Forms::FeeApproval.new(application.detail)
      end

      def approve_save
        @form = Forms::FeeApproval.new(application.detail)
        @form.update_attributes(update_approve_params)

        if @form.save
          redirect_to DetailsRouter.new(application).savings_or_summary
        else
          render :approve
        end
      end

      private

      def reset_fee_manager_approval_fields
        detail = application.detail

        if detail.fee <= 10_000
          detail.update(fee_manager_firstname: nil, fee_manager_lastname: nil)
        end
      end

      def user_jurisdictions
        current_user.office.jurisdictions
      end

      def update_approve_params
        params.require(:application).permit(*Forms::FeeApproval.permitted_attributes.keys)
      end
    end
  end
end
