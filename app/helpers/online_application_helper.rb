module OnlineApplicationHelper

  private

  def fee_under_threshold
    reset_fee_manager_approval_fields
    if display_paper_evidence_page?
      redirect_to benefits_online_application_path(online_application)
    else
      redirect_to action: :show
    end
  end

  def display_paper_evidence_page?
    return false if online_application.benefits == false || savings_exceeded
    return true if DwpMonitor.new.state == 'offline' && DwpWarning.state != DwpWarning::STATES[:online]
    !online_benefit_check
  end

  def savings_exceeded
    if ucd_changes_apply?(online_application)
      !band_saving_calculation_passed?
    else
      !SavingsPassFailService.new(Saving.new).calculate_online_application(online_application)
    end
  end

  def reset_fee_manager_approval_fields
    online_application.update(fee_manager_firstname: nil, fee_manager_lastname: nil)
  end

  def online_benefit_check
    OnlineBenefitCheckRunner.new(online_application).run
    last_benefit_check = online_application.last_benefit_check
    return false unless last_benefit_check
    last_benefit_check.benefits_valid?
  end

  def ucd_changes_apply?(online_application)
    FeatureSwitching::CALCULATION_SCHEMAS[1].to_s == online_application.calculation_scheme
  end

  def band_saving_calculation_passed?
    band = BandBaseCalculation.new(online_application)
    band.remission
    band.saving_passed?
  end

  def check_completed_redirect
    set_cache_headers
    if online_application.processed?
      flash[:alert] = I18n.t('application_redirect.processed')
      redirect_to application_confirmation_path(online_application.linked_application)
    end
  end

  def decide_next_step(form)
    if form.discretion_applied == false
      discretion_not_applied_redirect(form)
    elsif form.fee < Settings.fee_approval_threshold
      fee_under_threshold
    else
      redirect_to action: :approve
    end
  end

  def discretion_not_applied_redirect(form)
    form.reset_date_received_data
    flash[:alert] = t('application_redirect.discretion_not_applied', reference: online_application.reference)
    redirect_to root_url
  end
end
