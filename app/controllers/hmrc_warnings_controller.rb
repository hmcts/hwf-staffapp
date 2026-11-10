class HmrcWarningsController < ApplicationController

  def edit
    authorize hmrc_warning
  end

  def update
    authorize hmrc_warning

    notice_message =
      if hmrc_warning.update(notification_params)
        'Your changes have been saved.'
      else
        'Your changes have not been saved.'
      end

    redirect_to edit_hmrc_warnings_path, notice: notice_message
  end

  private

  def hmrc_warning
    @hmrc_warning = HmrcWarning.first_or_create
  end

  def notification_params
    params.require(:hmrc_warning).permit(:check_state)
  end
end
