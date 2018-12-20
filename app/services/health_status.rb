class HealthStatus
  # rubocop:disable Metrics/MethodLength
  def self.current_status
    services = {
      database: {
        description: "Postgres database", ok: database
      },
      smtp: {
        description: "SendGrid", ok: smtp
      },
      api: {
        description: "DWP API", ok: api
      }
    }
    services.merge(ok: services.all? { |_, value| value[:ok] })
  end

  def self.database
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end

  def self.smtp
    host = ActionMailer::Base.smtp_settings[:address]
    port = ActionMailer::Base.smtp_settings[:port]
    begin
      Net::SMTP.start(host, port) do |smtp|
        smtp.enable_starttls_auto
        smtp.ehlo(Socket.gethostname)
        smtp.finish
      end
      true
    rescue StandardError => error
      Rails.logger.error "The SMTP server errored with: #{error}"
      false
    end
  end

  def self.api
    DwpMonitor.new.state == 'online'
  rescue StandardError => error
    Rails.logger.error "The DWP API errored with: #{error}"
    false
  end
  # rubocop:enable Metrics/MethodLength
end
