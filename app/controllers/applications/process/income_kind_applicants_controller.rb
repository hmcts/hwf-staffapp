module Applications
  module Process
    class IncomeKindApplicantsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if application.benefits?
          redirect_to application_summary_path(application)
        else
          @form = Forms::Application::IncomeKindApplicant.new(application)
          map_income_kind_applicant
          render :index
        end
      end

      def create
        @form = Forms::Application::IncomeKindApplicant.new(application)
        @form.update(allowed_params_applicant)

        if @form.save
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def path_to_next_page
        if married?
          application_income_kind_partners_path(application)
        else
          application_incomes_path(application)
        end
      end

      def married?
        application.applicant.married?
      end

      def allowed_params_applicant
        params.require(:application).permit(income_kind_applicant: []).to_h
      rescue ActionController::ParameterMissing
        {}
      end

      def map_income_kind_applicant
        return [] if application.income_kind.blank?
        list = application.income_kind[:applicant].try(:map, &:to_i)
        @form.income_kind_applicant = list
      end
    end
  end
end
