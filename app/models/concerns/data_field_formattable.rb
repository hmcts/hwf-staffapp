module DataFieldFormattable
  extend ActiveSupport::Concern

  def format_the_dates?(date_attr_name)
    date = send(date_attr_name.to_s)
    day = send("day_#{date_attr_name}")
    month = send("month_#{date_attr_name}")
    year = send("year_#{date_attr_name}")

    !(day.blank? && month.blank? && year.blank? && date.present?)
  end

  def format_dates(date_attr_name)
    instance_variable_set("@#{date_attr_name}", concat_dates(date_attr_name).to_date)
  rescue ArgumentError
    instance_variable_set("@#{date_attr_name}", concat_dates(date_attr_name))
  end

  def concat_dates(date_attr_name)
    day = send("day_#{date_attr_name}")
    month = send("month_#{date_attr_name}")
    year = send("year_#{date_attr_name}")
    return '' if day.blank? || month.blank? || year.blank?

    "#{day}/#{month}/#{year}"
  end

end
