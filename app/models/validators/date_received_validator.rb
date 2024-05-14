class Validators::DateReceivedValidator < ActiveModel::Validator

  def validate(record)
    @validate_record = record
    received = record.date_received

    if received.blank?
      record.errors.add :date_received, I18n.t("#{translation_prefix}.blank")
    elsif received.is_a?(String)
      begin
        Date.parse(received)
      rescue
        record.errors.add :date_received, I18n.t("#{translation_prefix}.not_a_date")
      end
    elsif after_or_equal_min_date(received)
      record.errors.add :date_received, I18n.t("#{translation_prefix}.date_after_or_equal_to")
    elsif before_tomorrow(received)
      record.errors.add :date_received, I18n.t("#{translation_prefix}.date_before")
    elsif before_or_equal_to_submitt_date(received)
      record.errors.add :date_received, I18n.t("#{translation_prefix}.before_submit")
    end

  end

  def min_date
    3.months.ago.midnight
  end

  def tomorrow
    Time.zone.tomorrow
  end

  def submitted_date
    @validate_record.submitted_at.to_date
  end

  def after_or_equal_min_date(received)
    received <= min_date
  end

  def before_tomorrow(received)
    tomorrow < received
  end

  def before_or_equal_to_submitt_date(received)
    return true if received < submitted_date
    (received - 3.months) >= submitted_date
  end

  def translation_prefix
    '.activemodel.errors.models.forms/application/detail.attributes.date_received'
  end

end