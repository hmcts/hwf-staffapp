class DwpCheckerController < ApplicationController

  respond_to :html

  def new
    @dwp_check = DwpCheck.new
  end

  def lookup
    @dwp_check = DwpCheck.new(dwp_params)

    if @dwp_check.valid?
      @dwp_check.created_by_id = current_user.id
      @dwp_check.benefits_valid = get_dwp_result(@dwp_check)
      if @dwp_check.save
        # render json: get_dwp_result(@dwp_check)
        respond_with(@dwp_check)
      else
        render action: :new
      end
    else
      render action: :new
    end
  end

  private

  def get_dwp_result(dwp_check)

    #todo create and call dwp lookup service
    #menawhile generate random true false response
    [true, false].sample==true
  end

  def dwp_params
    params.require(:dwp_check).permit(:last_name, :dob, :ni_number, :date_to_check)
  end
end
