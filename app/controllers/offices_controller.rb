class OfficesController < ApplicationController
  before_action :authenticate_user!
  before_action :list_jurisdictions, only: [:new, :edit, :update]

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
  end

  def create
    @office = Office.new(office_params)
    authorize @office

    @office.save
    respond_with(@office)
    flash[:notice] = 'Office was successfully created'
  end

  def update
    office.assign_attributes(office_params)
    authorize office

    if office.save && manager_setup.in_progress?
      redirect_to out_of_the_box_redirect
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
    @jurisdictions = Jurisdiction.all
  end

  def manager_setup
    @manager_setup ||= ManagerSetup.new(current_user, session)
  end

  def out_of_the_box_redirect
    manager_setup.setup_profile? ? edit_user_path(current_user) : root_path
  end
end
