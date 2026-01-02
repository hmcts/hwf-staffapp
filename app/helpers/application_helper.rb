module ApplicationHelper
  def hide_login_menu?(current_page)
    current_page.in?(['/users/sign_in', '/users/password/edit'])
  end

  def parse_amount_to_pay(amount_to_pay)
    return unless amount_to_pay
    (amount_to_pay % 1).zero? ? amount_to_pay.to_i : amount_to_pay
  end

  def amount_to_refund(application)
    amount_to_pay = application.evidence_check ? application.evidence_check.amount_to_pay : application.amount_to_pay
    application.detail.fee - amount_to_pay
  end

  def amount_to_pay(application)
    application.evidence_check ? application.evidence_check.amount_to_pay : application.amount_to_pay
  end

  def amount_value(value)
    return value.to_i if value.to_i.positive?
    nil
  end

  def selected_jurisdiction
    return nil unless params['filter_applications']
    params['filter_applications']["jurisdiction_id"]
  end

  def selected_order
    return nil unless params['filter_applications']
    params['filter_applications']["order_choice"]
  end

  def date_submitted(application)
    application.created_at.strftime("%d %b %Y")
  end

  def show_refund_section?
    !FeatureSwitching.active?(:band_calculation)
  end
  alias show_received_section? show_refund_section?
  alias hide_fee_status? show_refund_section?

  def show_ucd_changes?(calculation_scheme)
    return FeatureSwitching.active?(:band_calculation) if calculation_scheme.blank?
    calculation_scheme == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
  end

  def path_to_first_page(record)
    if FeatureSwitching.active?(:band_calculation)
      application_fee_status_path(record)
    else
      application_personal_informations_path(record)
    end
  end

  def previous_page_link
    return '' unless current_user
    path_storage = PathStorage.new(current_user)
    path_storage.path_back
  end

  def date_hint
    Time.current.strftime("%d %m %Y")
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def application_id_helper
    if @application.present?
      @application&.id
    elsif @evidence.present?
      @evidence&.application_id
    elsif @part_payment.present?
      @part_payment&.application_id
    end
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
