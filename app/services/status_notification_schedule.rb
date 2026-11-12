# Decides when a status monitor's down/up emails are due, so a long outage
# does not send one every five minutes - see CHANGELOG.md (RST-8807).
#
#   StatusNotificationSchedule.new('hmrc', HmrcMonitor.new.state).run do |email|
#     # email is :down or :up; send it here
#   end
class StatusNotificationSchedule
  INITIAL_EMAILS = 3
  # Checks run every 5 minutes; a minute of slack stops a slightly early cron run skipping an email.
  INITIAL_GAP = 4.minutes
  LATER_GAP = 29.minutes

  def initialize(service, monitor_state)
    @service = service
    @monitor_state = monitor_state
  end

  # Yields the email that is due, if any, then records it. If the block raises,
  # nothing is recorded, so the next check tries again.
  def run
    notification.with_lock do
      email = email_due
      next if email.nil?

      yield email
      record(email)
    end
  end

  private

  def notification
    @notification ||= StatusNotification.for(@service)
  end

  # Only offline and online count; 'warning' (amber) sends nothing and leaves an outage open.
  def email_due
    case @monitor_state
    when 'offline'
      :down if down_email_due?
    when 'online'
      :up if notification.outage_open?
    end
  end

  def down_email_due?
    return true unless notification.outage_open?

    Time.zone.now - notification.last_sent_at >= gap_before_next_email
  end

  def gap_before_next_email
    notification.sent_count < INITIAL_EMAILS ? INITIAL_GAP : LATER_GAP
  end

  def record(email)
    if email == :down
      notification.update!(outage_open: true, sent_count: notification.sent_count + 1, last_sent_at: Time.zone.now)
    else
      notification.update!(outage_open: false, sent_count: 0, last_sent_at: nil)
    end
  end
end
