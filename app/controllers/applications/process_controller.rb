module Applications
  class ProcessController < ApplicationController
    before_action :authenticate_user!

    def personal_information
      @form = Applikation::Forms::PersonalInformation.new(application.applicant)
    end

    def personal_information_save
      @form = Applikation::Forms::PersonalInformation.new(application.applicant)
      @form.update_attributes(personal_information_params)

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
      @form.update_attributes(application_defails_params)

      if @form.save
        hack_and_redirect
      else
        @jurisdictions = user_jurisdictions
        render :application_details
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
      @form.update_attributes(benefits_params)

      if @form.save
        redirect_to(application_build_path(application_id: application.id, id: :benefits_result))
      else
        render :benefits
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

    def personal_information_params
      permitted_attributes = *Applikation::Forms::PersonalInformation.permitted_attributes.keys
      params.require(:application).permit(permitted_attributes)
    end

    def application_defails_params
      permitted_attributes = *Applikation::Forms::ApplicationDetail.permitted_attributes.keys
      params.require(:application).permit(permitted_attributes)
    end

    def benefits_params
      permitted_attributes = *Applikation::Forms::Benefit.permitted_attributes.keys
      params.require(:application).permit(permitted_attributes)
    end

    def application
      Application.find(params[:application_id])
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
  end
end
