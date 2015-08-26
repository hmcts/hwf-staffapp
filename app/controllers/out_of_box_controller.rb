class OutOfBoxController < ApplicationController
  before_action :authenticate_user!

  respond_to :html

  def password
  end

  def office
  end

  def details
  end
end
