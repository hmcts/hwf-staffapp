module Applications
  # rubocop:disable ClassLength
  class ProcessController < ApplicationController
    before_action :authorise_application_update, except: :create

    def create
      application = ApplicationBuilder.new(current_user).build
      authorize application

      application.save
      redirect_to application_personal_information_path(application)
    end

    def personal_information
      @form = Forms::Application::Applicant.new(application.applicant)
    end

    def personal_information_save
      @form = Forms::Application::Applicant.new(application.applicant)
      @form.update_attributes(form_params(:applicant))

      if @form.save
        redirect_to(action: :application_details)
      else
        render :personal_information
      end
    end

    def application_details
      @form = Forms::Application::Detail.new(application.detail)
      @jurisdictions = user_jurisdictions
    end

    def application_details_save
      @form = Forms::Application::Detail.new(application.detail)
      @form.update_attributes(form_params(:details))

      if @form.save
        redirect_to(action: :savings_investments)
      else
        @jurisdictions = user_jurisdictions
        render :application_details
      end
    end

    def savings_investments
      @form = Forms::Application::SavingsInvestment.new(application)
    end

    def savings_investments_save
      @form = Forms::Application::SavingsInvestment.new(application)
      @form.update_attributes(form_params(:savings_investments))

      if @form.save
        redirect_to(action: :benefits)
      else
        render :savings_investments
      end
    end

    def benefits
      if application.savings_investment_valid?
        @form = Forms::Application::Benefit.new(application)
        render :benefits
      else
        redirect_to application_summary_path(application)
      end
    end

    def benefits_save
      @form = Forms::Application::Benefit.new(application)
      @form.update_attributes(form_params(:benefits))

      if @form.save
        benefit_check_and_redirect(@form.benefits)
      else
        render :benefits
      end
    end

    def income
      if !application.benefits?
        @form = Forms::Application::Income.new(application)
        render :income
      else
        redirect_to application_summary_path(application)
      end
    end

    def income_save
      @form = Forms::Application::Income.new(application)
      @form.update_attributes(form_params(:income))

      if @form.save
        IncomeCalculationRunner.new(application).run
        redirect_to(action: :summary)
      else
        render :income
      end
    end

    def summary
      @result = Views::Applikation::Result.new(application)
      @overview = Views::ApplicationOverview.new(application)
      @savings = Views::Overview::SavingsAndInvestments.new(application)
      @benefits = Views::Overview::Benefits.new(application)
      @income = Views::Overview::Income.new(application)
    end

    def summary_save
      ResolverService.new(application, current_user).complete
      redirect_to application_confirmation_path(application.id)
    end

    def confirmation
      if application.evidence_check.present?
        redirect_to(evidence_check_path(application.evidence_check.id))
      else
        @confirm = Views::Confirmation::Result.new(application)
      end
    end

    private

    def authorise_application_update
      authorize application, :update?
    end

    def form_params(type)
      class_name = "Forms::Application::#{type.to_s.classify}".constantize
      params.require(:application).permit(*class_name.permitted_attributes.keys)
    end

    def application
      @application ||= Application.find(params[:application_id])
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
      else
        redirect_to(action: :income)
      end
    end

    def determine_override
      if benefit_check_runner.can_override?
        redirect_to application_benefit_override_paper_evidence_path(application)
      else
        redirect_to(action: :summary)
      end
    end
  end
end
