class UsersController < ApplicationController
  respond_to :html
  before_action :authenticate_user!
  before_action :find_user, only: [:edit, :show, :update, :destroy]
  before_action :populate_roles, only: [:edit, :update]
  before_action :populate_offices, only: [:edit, :update]
  before_action :populate_jurisdictions, only: [:edit, :update]
  load_and_authorize_resource

  def index
    if current_user.admin?
      @users = User.sorted_by_email
    elsif current_user.manager?
      @users = User.by_office(current_user.office_id).where.not(role: 'admin').sorted_by_email
    end
  end

  def edit
    user_or_redirect
  end

  def show
    user_or_redirect
  end

  def update
    flash[:notice] = 'User updated' if @user.update_attributes(user_params)
    flash[:notice] = user_transfer_message if no_longer_manages?

    user_or_redirect
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  protected

  def user_params
    all_params   = [:name, :office_id, :jurisdiction_id, :role]
    all_but_role = [:name, :office_id, :jurisdiction_id]

    if current_user.admin? || manager_doesnt_escalate_to_admin?
      params.require(:user).permit(all_params)
    else
      params.require(:user).permit(all_but_role)
    end
  end

  def no_longer_manages?
    current_user.manager? && not_their_office?
  end

  def not_their_office?
    current_user.office != @user.office
  end

  def user_transfer_message
    office = @user.office
    t('error_messages.user.moved_offices',
      user: @user.name,
      office: office.name,
      contact: office.managers_email)
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

  def populate_jurisdictions
    @jurisdictions = @user.office.jurisdictions
  end

  def user_or_redirect
    if admin_manager_or_user_themselves?
      respond_with(@user)
    elsif current_user.manager?
      redirect_to users_path
    else
      redirect_to root_path
    end
  end

  def admin_manager_or_user_themselves?
    current_user.admin? || manages_user? || user_themselves?
  end

  def user_themselves?
    current_user.id == @user.id
  end

  def manages_user?
    current_user.manager? && current_user.office == @user.office
  end

  def manager_doesnt_escalate_to_admin?
    manages_user? && params[:user][:role] != 'admin'
  end
end
