module AlertNotifier
  def self.run!
    send_email_notifications if DwpMonitor.new.state == 'offline'
  end

  private
  def self.send_email_notifications
    ApplicationMailer.dwp_is_down_notifier.deliver_now
  end
end
