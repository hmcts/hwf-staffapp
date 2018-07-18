class DwpWarningsController < ApplicationController

  def edit
    authorize dwp_warning
  end

  def update
    authorize dwp_warning

    notice_message =
      if dwp_warning.update_attributes(notification_params)
        'Your changes have been saved.'
      else
        'Your changes have not been saved.'
      end

    redirect_to edit_dwp_warnings_path, notice: notice_message
  end

  private

  def dwp_warning
    @dwp_warning = DwpWarning.first_or_create
  end

  def notification_params
    params.require(:dwp_warning).permit(:check_state)
  end
end
