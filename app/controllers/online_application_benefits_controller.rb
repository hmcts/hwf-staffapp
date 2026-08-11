class OnlineApplicationBenefitsController < OnlineApplicationsController

  def edit
    @form = Forms::OnlineApplication.new(online_application)
    render :edit
  end

  def update
    @form = Forms::OnlineApplication.new(online_application)
    @form.update(update_params.merge(dwp_manual_decision: dwp_manual_decision))

    if @form.save
      decide_redirection
    else
      render :edit
    end
  end

  def retry
    return head :forbidden unless Settings.dwp_retry_button_enabled

    OnlineBenefitCheckRunner.new(online_application).run
    redirect_to benefits_online_application_path(online_application)
  end

  private

  def decide_redirection
    if dwp_blocks_processing?
      flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
      redirect_to root_url
    else
      redirect_to online_application_path(online_application)
    end
  end

  # When DWP is marked offline staff decide benefits manually (CHANGELOG.md)
  def dwp_blocks_processing?
    return false if DwpWarning.offline?
    online_application.benefit_check_with_error_message? && !benefits_override?
  end

  def benefits_override?
    online_application.benefits_override == true
  end

  def dwp_manual_decision
    # as default benefits_override attribute is false but we need tp track the response so
    # I added new attribute which as default is nil
    update_params[:benefits_override]
  end
end
