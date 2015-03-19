class DwpChecksController < ApplicationController
  before_action :authenticate_user!
  respond_to :html
  before_action :find_dwp_check, only: [:show]

  def new
    authorize! :new, DwpCheck
    @dwp_checker = DwpCheck.new
  end

  def lookup
    authorize! :lookup, DwpCheck
    @dwp_checker = DwpCheck.new(dwp_params)

    if @dwp_checker.valid?
      process_dwp_check
      if @dwp_checker.save
        # render json: get_dwp_result(@dwp_checker)
        redirect_to dwp_checks_path(@dwp_checker.unique_number)
        return
      end
    end
    render action: :new
  end

  def show
    authorize! :show, DwpCheck
  end

private

  def process_dwp_check
    @dwp_checker.created_by_id = current_user.id
    @dwp_checker.benefits_valid = dwp_result
  end

  def dwp_result
    params = {
      ni_number: @dwp_checker.ni_number,
      surname: @dwp_checker.last_name.upcase,
      birth_date: @dwp_checker.dob.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
    response = RestClient.post "#{ENV['DWP_API_PROXY']}/api/benefit_checks", params
    JSON.parse(response)['benefit_checker_status'] == 'Yes' ? true : false
  end

  def process_check_date
    check_date = @dwp_checker.date_to_check ? @dwp_checker.date_to_check : Date.today
    check_date.strftime('%Y%m%d')
  end

  def dwp_params
    params.require(:dwp_check).permit(:last_name, :dob, :ni_number, :date_to_check)
  end

  def find_dwp_check
    @dwp_checker = DwpCheck.find_by(unique_number: params[:unique_number])
  end
end
