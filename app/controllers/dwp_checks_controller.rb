class DwpChecksController < ApplicationController
  before_action :authenticate_user!
  respond_to :html
  before_action :find_dwp_check, only: [:show]
  before_action :new_from_params, only: [:lookup]
  def new
    authorize! :new, DwpCheck
    @dwp_checker = DwpCheck.new
  end

  def lookup
    authorize! :lookup, DwpCheck

    if @dwp_checker.valid?
      begin
        process_dwp_check
        return redirect_to dwp_checks_path(@dwp_checker.unique_number) if @dwp_checker.save
      rescue => e
        flash.now[:alert] = e.message
      end
    end
    render action: :new
  end

  def show
    authorize! :show, DwpCheck
  end

private

  def new_from_params
    @dwp_checker = DwpCheck.new(dwp_params)
  end

  def process_dwp_check
    @dwp_checker.created_by_id = current_user.id
    @dwp_checker.dwp_result = query_proxy_api
    @dwp_checker.benefits_valid = (@dwp_checker.dwp_result == 'Yes' ? true : false)
  end

  def query_proxy_api
    params = {
      ni_number: @dwp_checker.ni_number,
      surname: @dwp_checker.last_name.upcase,
      birth_date: @dwp_checker.dob.strftime('%Y%m%d'),
      entitlement_check_date: process_check_date
    }
    response = RestClient.post "#{ENV['DWP_API_PROXY']}/api/benefit_checks", params
    JSON.parse(response)['benefit_checker_status']
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
