class OfficesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_office, only: [:show, :edit, :update, :destroy]
  before_action :list_jurisdictions, only: [:new, :edit]

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
    @office.update(office_params)
    respond_with(@office)
  end

  def destroy
    @office.destroy
    respond_with(@office)
  end

private

  def set_office
    @office = Office.find(params[:id])
  end

  def office_params
    params.require(:office).permit(:name, jurisdiction_ids: [])
  end

  def list_jurisdictions
    @jurisdictions = Jurisdiction.all
  end
end
