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

    def summary
      @result = Views::Applikation::Result.new(application)
      @overview = Views::ApplicationOverview.new(application)
    end

    def confirmation
      if evidence_check_enabled? && application.evidence_check?
        redirect_to(evidence_check_path(application.evidence_check.id))
      else
        @application = application
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
        # Fixme: this is a temporary hack to trigger the after_save callback on the Application, which has to run
        #        when the benefit checker and income calculators are removed from it, this should be as well
        application.update(status: application.status)
        redirect_to(application_build_path(application.id, :savings_investments))
      else
        @jurisdictions = user_jurisdictions
        render :application_details
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

    def application
      Application.find(params[:application_id])
    end

    def user_jurisdictions
      current_user.office.jurisdictions
    end
  end
end
