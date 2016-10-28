class MailService

  def initialize(data_source)
    @data_source = data_source
  end

  def send_public_confirmation
    return false unless source_is_valid_for_public_confirmation
    email = email_template
    email.deliver_later
  end

  private

  def source_is_valid_for_public_confirmation
    source_is_valid && @data_source.is_a?(OnlineApplication) && @data_source.email_address.present?
  end

  def source_is_valid
    @data_source.present?
  end

  def email_template
    if data_source_et?
      PublicMailer.submission_confirmation_et(@data_source)
    elsif @data_source.refund?
      PublicMailer.submission_confirmation_refund(@data_source)
    else
      PublicMailer.submission_confirmation(@data_source)
    end
  end

  def data_source_et?
    @data_source.form_name.present? && !(@data_source.form_name =~ /^ET/).nil?
  end
end
