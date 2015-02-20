class DwpChecksController < ApplicationController
  before_action :authenticate_user!


  respond_to :html
  before_action :get_dwp_check, only: [:show]

  def new
    authorize! :new, DwpCheck
    @dwp_checker = DwpCheck.new
  end

  def lookup
    authorize! :lookup, DwpCheck
    @dwp_checker = DwpCheck.new(dwp_params)

    if @dwp_checker.valid?
      @dwp_checker.created_by_id = current_user.id
      @dwp_checker.benefits_valid = get_dwp_result
      if @dwp_checker.save
        # render json: get_dwp_result(@dwp_checker)
        redirect_to dwp_checks_path(@dwp_checker.unique_number)
        # respond_with @dwp_checker
      else
        render action: :new
      end
    else
      render action: :new
    end
  end

  def show
    authorize! :show, DwpCheck
  end

  private

  def get_dwp_result
    #todo create and call dwp lookup service
    #menawhile generate random true false response
    [true, false].sample==true
  end

  def dwp_params
    params.require(:dwp_check).permit(:last_name, :dob, :ni_number, :date_to_check)
  end

  def get_dwp_check
    @dwp_checker =DwpCheck.find_by(unique_number: params[:unique_number])
  end
end
