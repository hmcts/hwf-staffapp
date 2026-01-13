class NotificationsController < ApplicationController
  def edit
    authorize notification
  end

  def update
    authorize notification

    notice_message =
      if notification.update(notification_params)
        'Your changes have been saved.'
      else
        'Your changes have not been saved.'
      end

    redirect_to edit_notifications_path, notice: notice_message
  end

  private

  def notification
    @notification = Notification.order(:id).first_or_create
  end

  def notification_params
    params.require(:notification).permit(:message, :show)
  end
end
