module ReportHelper
  def ocmc_courts
    Office.sorted.non_digital
  end

  def preformat_average_time(averege_time)
    parts = averege_time.parts
    hours = parts[:hours] || '00'
    minutes = format_minutes(parts[:minutes])
    seconds = parts[:seconds] || 0

    "#{hours}:#{minutes}:#{seconds.round(0)}"
  end

  private

  def format_minutes(minutes)
    return '00' unless minutes
    return "0#{minutes}" if minutes < 9
    minutes
  end
end
