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
        redirect_to(application_build_path(application.id, :application_details))
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
    end

    def application_details_save
    end

    private

    def personal_information_params
      permitted_attributes = *Applikation::Forms::PersonalInformation.permitted_attributes.keys
      params.require(:application).permit(permitted_attributes)
    end

    def application
      Application.find(params[:application_id])
    end
  end
end
