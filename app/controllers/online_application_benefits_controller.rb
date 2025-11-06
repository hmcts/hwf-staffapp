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

  private

  def decide_redirection
    if allow_benefit_override? && !benefits_override?
      flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
      redirect_to root_url
    else
      redirect_to online_application_path(online_application)
    end
  end

  def allow_benefit_override?
    online_application.benefit_check_with_error_message? || DwpWarning.last&.check_state == DwpWarning::STATES[:offline]
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
