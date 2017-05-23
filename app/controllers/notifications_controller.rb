class NotificationsController < ApplicationController
  def edit
    authorize notification
  end

  def update
    authorize notification

    notice_message =
      if notification.update_attributes(notification_params)
        'Your changes have been saved.'
      else
        'Your changes have not been saved.'
      end

    redirect_to edit_notifications_path, notice: notice_message
  end

  private

  def notification
    @notification = Notification.first
  end

  def notification_params
    params.require(:notification).permit(:message, :show)
  end
end
