class OnlineApplicationBenefitsController < OnlineApplicationsController

  def edit
    @form = Forms::OnlineApplication.new(online_application)
    render :edit
  end

  def update
    @form = Forms::OnlineApplication.new(online_application)
    @form.update_attributes(update_params)

    if @form.save
      decide_redirection
    else
      render :edit
    end
  end

  private

  def decide_redirection
    if @form.benefits_override || last_benefit_check_result_is_no
      redirect_to online_application_path(online_application)
    else
      flash[:alert] = t('error_messages.benefit_check.cannot_process_application')
      redirect_to root_url
    end
  end

  def last_benefit_check_result_is_no
    return false if online_application.last_benefit_check.blank?
    online_application.last_benefit_check.dwp_result == 'No'
  end
end
