class UsersController < ApplicationController
  respond_to :html
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.sorted_by_email
  end

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    flash[:notice] = 'User updated' if @user.update_attributes(user_params)
    redirect_to users_path
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    @user
  end

protected

  def user_params
    params.require(:user).permit(:email, :role)
  end
end
