class OutOfBoxController < ApplicationController
  before_action :authenticate_user!

  respond_to :html

  def password
  end

  def office
     @office = current_user.office
     @jurisdictions = Jurisdiction.all
  end

  def details
    @user = current_user
    @jurisdictions = Jurisdiction.all
    @roles = User::ROLES
    @offices = Office.all
  end
end
