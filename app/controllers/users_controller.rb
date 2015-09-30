class UsersController < ApplicationController
  respond_to :html
  before_action :authenticate_user!
  before_action :find_user, only: [:edit, :show, :update, :destroy]
  before_action :find_deleted_user, only: [:restore]
  before_action :populate_lookups, only: [:edit, :update]
  load_and_authorize_resource

  include FlashMessageHelper

  def index
    if current_user.admin?
      @users = User.sorted_by_email
    elsif current_user.manager?
      @users = User.by_office(current_user.office_id).where.not(role: 'admin').sorted_by_email
    end
  end

  def deleted
    authorize! :list_deleted, User
    @users = User.only_deleted.sorted_by_email
  end

  def edit
    user_or_redirect
  end

  def show
    user_or_redirect
  end

  def update
    update_successful = @user.update_attributes(user_params)
    if update_successful && manager_setup.in_progress?
      redirect_to root_path
    else
      flash_notices_for_update(update_successful)
      user_or_redirect
    end
  end

  def destroy
    if UserManagement.new(current_user, @user).user_themselves?
      flash[:alert] = 'You cannot delete your own account'
      redirect_to user_path(@user)
    else
      @user.destroy
      redirect_to users_path
    end
  end

  def restore
    @user.restore
    redirect_to redirect_after_restore
  end

  protected

  def flash_notices_for_update(update_successful)
    flash[:notice] = 'User updated' if update_successful
    flash[:notice] = user_transfer_notice if UserManagement.new(current_user, @user).transferred?
  end

  def user_params
    all_params   = [:name, :office_id, :jurisdiction_id, :role]
    all_but_role = [:name, :office_id, :jurisdiction_id]

    if UserManagement.new(current_user, @user).manager_cant_escalate_to_admin?(params[:user][:role])
      params.require(:user).permit(all_params)
    else
      params.require(:user).permit(all_but_role)
    end
  end

  def user_transfer_notice
    office = @user.office
    t('error_messages.user.moved_offices',
      user: @user.name,
      office: office.name,
      contact: format_managers_contacts(office.managers))
  end

  def find_user
    @user = User.find(params[:id])
  end

  def find_deleted_user
    @user = User.only_deleted.find(params[:id])
  end

  def populate_lookups
    if current_user.admin?
      @roles = User::ROLES
    else
      @roles = User::ROLES - %w[admin]
    end
    @offices = Office.all
    @jurisdictions = @user.office.jurisdictions
  end

  def user_or_redirect
    if UserManagement.new(current_user, @user).admin_manager_or_user_themselves?
      respond_with(@user)
    elsif current_user.manager?
      redirect_to users_path
    else
      redirect_to root_path
    end
  end

  def redirect_after_restore
    User.only_deleted.count > 0 ? deleted_users_path : users_path
  end

  def manager_setup
    @manager_setup ||= ManagerSetup.new(current_user, session)
  end
end
