module AlertNotifier
  class << self
    def run!
      send_email_notifications if DwpMonitor.new.state == 'offline'
    end

    private

    def send_email_notifications
      ApplicationMailer.dwp_is_down_notifier.deliver_now
    end
  end
end
