class OfficesController < ApplicationController
  before_action :list_jurisdictions, only: [:edit, :update]

  respond_to :html

  def index
    authorize :office

    @offices = Office.sorted
    respond_with(@offices)
  end

  def show
    authorize office

    respond_with(office)
  end

  def new
    @office = Office.new
    authorize @office

    respond_with(@office)
  end

  def edit
    authorize office

    @becs = Hash[@office.business_entities.map { |be| [be.jurisdiction_id, be.code] }]
  end

  def create
    @office = Office.new(office_params)
    authorize @office

    flash[:notice] = 'Office was successfully created' if @office.save

    respond_with(@office)
  end

  def update
    office.assign_attributes(office_params)
    authorize office

    if office.save
      flash[:notice] = 'Office was successfully updated'

      redirect_to update_redirect_path
    else
      respond_with(office)
    end
  end

  private

  def office
    @office ||= Office.find(params[:id])
  end

  def office_params
    params.require(:office).permit(:name, :entity_code, jurisdiction_ids: [])
  end

  def list_jurisdictions
    @jurisdictions = Jurisdiction.available_for_office(office)
  end

  def manager_setup
    @manager_setup ||= ManagerSetup.new(current_user, session)
  end

  def update_redirect_path
    manager_setup.in_progress? ? out_of_the_box_redirect : { action: :show }
  end

  def out_of_the_box_redirect
    manager_setup.setup_profile? ? edit_user_path(current_user) : root_path
  end
end
