class Applications::ProcessController < ApplicationController
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

  def personal_information_params
    params.require(:personal_information).permit(*Applikation::Forms::PersonalInformation.permitted_attributes.keys)
  end

  private

  def application
    Application.find(params[:application_id])
  end
end
