class MailService

  def initialize(data_source)
    @data_source = data_source
  end

  def send_public_confirmation
    return false unless source_is_valid_for_public_confirmation
    email = if @data_source.refund?
              OnlineMailer.refund_confirmation(@data_source)
            else
              OnlineMailer.confirmation(@data_source)
            end
    email.deliver_now
  end

  private

  def source_is_valid_for_public_confirmation
    source_is_valid && @data_source.is_a?(OnlineApplication) && @data_source.email_address.present?
  end

  def source_is_valid
    @data_source.present?
  end
end
