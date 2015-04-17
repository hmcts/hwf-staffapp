class CalculatorController < ApplicationController
  respond_to :html, :json
  before_action :authenticate_user!

  def income
    authorize! :create, R2Calculator
  end

  def record_search
    authorize! :record_search, R2Calculator
    @r2_calculator = create_from_params

    respond_to do |format|
      if @r2_calculator.save
        format.json { render json: @r2_calculator, status: :created }
      else
        format.json { render json: @r2_calculator.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def create_from_params
    @r2 = R2Calculator.new(r2_calc_params)
    @r2.created_by_id = current_user.id
    @r2
  end

  def r2_calc_params
    params.require(:r2_calculator).permit(:fee, :married, :children, :income, :remittance, :to_pay)
  end
end
