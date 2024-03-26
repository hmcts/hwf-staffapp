class Users::FileDownloadController < ApplicationController
  respond_to :html

  def show
    authorize :user

    @storage_record = ExportFileStorage.find(params[:file_id])
    # check the user user_id: current_user.id,
  end
end