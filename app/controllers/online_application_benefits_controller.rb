class OnlineApplicationBenefitsController < OnlineApplicationsController

  def edit
    @form = Forms::OnlineApplication.new(online_application)
    render :edit
  end

  def update
    @form = Forms::OnlineApplication.new(online_application)
    @form.update(update_params)

    if @form.save
      decide_redirection
    else
      render :edit
    end
  end

  private

  def decide_redirection
    if online_application.failed_because_dwp_error?
      flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
      redirect_to root_url
    else
      redirect_to online_application_path(online_application)
    end
  end
end
