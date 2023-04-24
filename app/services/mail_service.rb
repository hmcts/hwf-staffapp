class MailService

  def initialize(data_source, locale = 'en')
    @data_source = data_source
    @locale = locale
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
    return NotifyMailer.submission_confirmation_refund(@data_source, @locale) if @data_source.refund?

    raise "applying_method is nil, reference: #{@data_source.reference}" if @data_source.applying_method.blank?

    if @data_source.applying_method == 'online'
      NotifyMailer.submission_confirmation_online(@data_source, @locale)
    else
      NotifyMailer.submission_confirmation_paper(@data_source, @locale)
    end
  end
end
