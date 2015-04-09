class CalculatorController < ApplicationController
  respond_to :html
  before_action :authenticate_user!

  def income
    authorize! :create, R2Calculator
  end
end
