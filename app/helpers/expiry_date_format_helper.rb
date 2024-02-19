module ExpiryDateFormatHelper

  def expiry_date_format(date)
    date.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
  end
end
