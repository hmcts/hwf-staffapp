class Applications::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :find_application, only: [:show, :update]

  steps :personal_information, :summary

  def create
    @application = Application.create
    redirect_to wizard_path(steps.first, application_id: @application.id)
  end

  def show
    render_wizard
  end

  def update
    params[:application][:status] = (step == steps.last) ? 'active' : step.to_s
    @application.update(application_params)
    render_wizard @application
  end

  private

  def find_application
    @application = Application.find(params[:application_id])
  end

  def application_params
    params.require(:application).permit(
      :title,
      :first_name,
      :last_name,
      :date_of_birth,
      :ni_number,
      :married,
      :status
    )
  end
end
