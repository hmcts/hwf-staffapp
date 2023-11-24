module Applications
  module Process
    class IncomeKindPartnersController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if application.benefits?
          redirect_to application_summary_path(application)
        else
          @form = Forms::Application::IncomeKindPartner.new(application)
          map_income_kind_partner
          render :index
        end
      end

      def create
        @form = Forms::Application::IncomeKindPartner.new(application)
        @form.update(allowed_params_partner)

        if @form.save
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def path_to_next_page
        application_incomes_path(application)
      end

      def married?
        application.applicant.married?
      end

      def allowed_params_partner
        params.require(:application).permit(income_kind_partner: []).to_h
      rescue ActionController::ParameterMissing
        {}
      end

      def map_income_kind_partner
        return [] if application.income_kind.blank?
        list = application.income_kind[:partner].try(:map, &:to_i)
        @form.income_kind_partner = list
      end
    end
  end
end
