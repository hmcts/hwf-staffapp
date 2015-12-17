class OutputsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :access, :outputs
  end
end
