class OutputsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :access, :outputs
  end

  def finance_report
    authorize! :access, :outputs
    @form = Forms::FinanceReport.new
  end
end
