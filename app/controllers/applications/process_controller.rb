module Applications
  # rubocop:disable ClassLength
  class ProcessController < ApplicationController
    before_action :authenticate_user!

    def personal_information
      @form = Applikation::Forms::PersonalInformation.new(application.applicant)
    end

    def personal_information_save
      @form = Applikation::Forms::PersonalInformation.new(application.applicant)
      @form.update_attributes(form_params(:personal_information))

      if @form.save
        redirect_to(action: :application_details)
      else
        render :personal_information
      end
    end

    def application_details
      @form = Applikation::Forms::ApplicationDetail.new(application.detail)
      @jurisdictions = user_jurisdictions
    end

    def application_details_save
      @form = Applikation::Forms::ApplicationDetail.new(application.detail)
      @form.update_attributes(form_params(:application_details))

      if @form.save
        hack_and_redirect
      else
        @jurisdictions = user_jurisdictions
        render :application_details
      end
    end

    def savings_investments
      @application = application
      @form = Applikation::Forms::SavingsInvestment.new(application)
    end

    def savings_investments_save
      @form = Applikation::Forms::SavingsInvestment.new(application)
      @form.update_attributes(form_params(:savings_investments))

      if @form.save
        redirect_to(action: :benefits)
      else
        @application = application
        render :savings_investments
      end
    end

    def benefits
      if application.savings_investment_valid?
        @form = Applikation::Forms::Benefit.new(application)
        render :benefits
      else
        redirect_to application_summary_path(application)
      end
    end

    def benefits_save
      @form = Applikation::Forms::Benefit.new(application)
      @form.update_attributes(form_params(:benefits))

      if @form.save
        BenefitCheckRunner.new(application).run
        redirect_to(action: :benefits_result)
      else
        render :benefits
      end
    end

    def benefits_result
      if application.benefits
        @application = application
        render :benefits_result
      else
        redirect_to(application_build_path(application_id: application.id, id: :income))
      end
    end

    def income
      if !application.benefits?
        @form = Applikation::Forms::Income.new(application)
        render :income
      else
        redirect_to application_summary_path(application)
      end
    end

    def income_save
      @form = Applikation::Forms::Income.new(application)
      @form.update_attributes(form_params(:income))

      if @form.save
        calculate_income
        evidence_check_and_payment
        redirect_to(application_build_path(application_id: application.id, id: :income_result))
      else
        render :income
      end
    end

    def income_result
      if application.application_type == 'income'
        @application = application
        render :income_result
      else
        redirect_to(application_summary_path(application))
      end
    end

    def summary
      @result = Views::Applikation::Result.new(application)
      @overview = Views::ApplicationOverview.new(application)
    end

    def confirmation
      if application.evidence_check?
        redirect_to(evidence_check_path(application.evidence_check.id))
      else
        @application = application
      end
    end

    private

    def form_params(type)
      class_name = "Applikation::Forms::#{type.to_s.classify}".constantize
      params.require(:application).permit(*class_name.permitted_attributes.keys)
    end

    def application
      @appication ||= Application.find(params[:application_id])
    end

    def user_jurisdictions
      current_user.office.jurisdictions
    end

    def hack_and_redirect
      # FIXME: this is a temporary hack to trigger the after_save callback on the Application,
      #        which has to run when the benefit checker and income calculators are removed
      #        from it, this should be as well
      application.update(status: application.status)
      redirect_to(application_build_path(application.id, :savings_investments))
    end

    def calculate_income
      IncomeCalculationRunner.new(application).run
    end

    def evidence_check_and_payment
      EvidenceCheckSelector.new(application, Settings.evidence_check.expires_in_days).decide!
      PaymentBuilder.new(application, Settings.payment.expires_in_days).decide!
    end
  end
end
