class Applications::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :find_application, only: [:show, :update]
  before_action :populate_jurisdictions, only: [:show, :update]

  steps :personal_information, :application_details, :summary

  def create
    @application = Application.create(jurisdiction_id: current_user.jurisdiction_id)
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

  def application_params # rubocop:disable Metrics/MethodLength
    params.require(:application).permit(
      # Page 1
      :title,
      :first_name,
      :last_name,
      :date_of_birth,
      :ni_number,
      :married,
      # Page 2
      :fee,
      :jurisdiction_id,
      :date_received,
      :form_name,
      :case_number,
      :probate,
      :deceased_name,
      :date_of_death,
      :refund,
      :date_fee_paid,
      :status
    )
  end

  def populate_jurisdictions
    @jurisdictions = current_user.office.jurisdictions
  end
end
