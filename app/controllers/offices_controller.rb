class OfficesController < ApplicationController

  before_action :set_office, only: [:show, :edit, :update, :destroy]

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
    puts "++++++ DEBUG notice ++++++ #{__FILE__}::#{__LINE__} ++++\n"
    
    @office = Office.new
    respond_with(@office)
  end

  def edit
  end

  def create
    @office.save
    respond_with(@office)
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
      params.require(:office).permit(:name)
    end
end
