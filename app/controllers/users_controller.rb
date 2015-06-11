class UsersController < ApplicationController
  respond_to :html
  before_action :authenticate_user!
  before_action :find_user, only: [:edit, :show, :update]
  before_action :populate_roles, only: [:edit, :update]
  before_action :populate_offices, only: [:edit, :update]
  load_and_authorize_resource

  def index
    if current_user.admin?
      @users = User.sorted_by_email
    elsif current_user.manager?
      @users = User.by_office(current_user.office_id).where.not(role: 'admin').sorted_by_email
    end
  end

  def edit
  end

  def show
  end

  def update
    flash[:notice] = 'User updated' if @user.update_attributes(user_params)
    if current_user_can_change_office?(@user)
      flash[:notice] = user_transfer_message(@user)
      return redirect_to users_path
    end
    respond_with(@user)
  end

protected

  def user_params
    params.require(:user).permit(:name, :role, :office_id)
  end

  def current_user_can_change_office?(user)
    current_user.manager? && (user.office != current_user.office)
  end

  def user_transfer_message(user)
    office = user.office
    t('error_messages.user.moved_offices',
      user: user.name,
      office: office.name,
      contact: office.managers_email
    )
  end

  def find_user
    @user = User.find(params[:id])
  end

  def populate_roles
    if current_user.admin?
      @roles = User::ROLES
    else
      @roles = User::ROLES - %w[admin]
    end
  end

  def populate_offices
    @offices = Office.all
  end
end
