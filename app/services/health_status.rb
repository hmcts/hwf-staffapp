class HealthStatus

  def self.current_status
    services = {
      database: {
        description: "Postgres database", ok: database
      },
      smtp: {
        description: "SMTP server", ok: smtp
      }
    }
    services.merge(services.all? { |service| service[:ok] })
  end

  def self.database
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end

  # rubocop:disable Metrics/MethodLength
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
end
