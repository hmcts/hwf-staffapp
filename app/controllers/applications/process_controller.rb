module Applications
  class ProcessController < ApplicationController
    before_action :authorize_application_update, except: :create
    before_action :check_completed_redirect, except: [:create, :confirmation, :override]
    before_action :set_cache_headers, only: [:confirmation]

    def create
      application = ApplicationBuilder.new(current_user).build
      authorize application

      application.save
      redirect_to application_personal_informations_path(application)
    end

    private

    def build_override_params
      form_params(:decision_override).merge(created_by_id: current_user.id)
    end

    def authorize_application_update
      authorize application, :update?
    end

    def check_completed_redirect
      set_cache_headers
      unless application.created?
        redirect_data = CompletedApplicationRedirect.new(application)
        flash[:alert] = redirect_data.flash_message
        redirect_to redirect_data.path
      end
    end

    def form_params(type)
      class_name = "Forms::Application::#{type.to_s.classify}".constantize
      params.require(:application).permit(*class_name.permitted_attributes.keys)
    end

    def application
      @application ||= Application.find(params[:application_id])
    end

    def decision_override
      @decision_override ||= DecisionOverride.find_or_initialize_by(application: application)
    end

    def user_jurisdictions
      current_user.office.jurisdictions
    end

    def benefit_check_runner
      @benefit_check_runner ||= BenefitCheckRunner.new(application)
    end

    def benefit_check_and_redirect(benefits)
      if benefits
        benefit_check_runner.run
        determine_override
      elsif benefits && no_benefits_paper_evidence?
        redirect_to application_benefit_override_paper_evidence_path(application)
      else
        redirect_to application_incomes_path(application)
      end
    end

    def determine_override
      if benefit_check_runner.can_override?
        redirect_to application_benefit_override_paper_evidence_path(application)
      else
        redirect_to application_summary_path(application)
      end
    end

    def no_benefits_paper_evidence?
      if application.detail.refund?
        !BenefitCheckRunner.new(application).benefit_check_date_valid?
      end
    end
  end
end
