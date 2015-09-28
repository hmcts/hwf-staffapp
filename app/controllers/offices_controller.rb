class OfficesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_office, only: [:show, :edit, :update, :destroy]
  before_action :list_jurisdictions, only: [:new, :edit, :update]

  load_and_authorize_resource

  respond_to :html

  def index
    @offices = Office.sorted
    respond_with(@offices)
  end

  def show
    respond_with(@office)
  end

  def new
    @office = Office.new
    respond_with(@office)
  end

  def edit
  end

  def create
    @office = Office.new(office_params)
    @office.save
    respond_with(@office)
    flash[:notice] = 'Office was successfully created'
  end

  def update
    if @office.update(office_params) && manager_setup.in_progress?
      redirect_to out_of_the_box_redirect
    else
      respond_with(@office)
    end
  end

  private

  def set_office
    @office = Office.find(params[:id])
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
