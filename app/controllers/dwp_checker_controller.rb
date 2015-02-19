class DwpCheckerController < ApplicationController

  respond_to :html
  before_action :get_dwp_check, only: [:show]

  def new
    @dwp_checker = DwpCheck.new
  end

  def lookup
    @dwp_checker = DwpCheck.new(dwp_params)

    if @dwp_checker.valid?
      @dwp_checker.created_by_id = current_user.id
      @dwp_checker.benefits_valid = get_dwp_result
      if @dwp_checker.save
        # render json: get_dwp_result(@dwp_checker)
        redirect_to dwp_checker_path(@dwp_checker.id)
        # respond_with @dwp_checker
      else
        render action: :new
      end
    else
      render action: :new
    end
  end
  def show
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
    @dwp_checker = DwpCheck.find(params[:id])
  end
end
