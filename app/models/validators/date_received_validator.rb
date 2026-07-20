module Validators
  class DateReceivedValidator < ActiveModel::Validator

    def validate(record)
      @validate_record = record
      @date_received_value = record.date_received

      if @date_received_value.blank?
        add_error(I18n.t("#{translation_prefix}.blank"))
      elsif @date_received_value.is_a?(String)
        parse_string_date
      else
        validate_ranges
      end
    end

    def validate_ranges
      if before_tomorrow
        add_error(I18n.t("#{translation_prefix}.date_before"))
      elsif iac_jurisdiction?
        validate_iac_ranges
      else
        validate_standard_ranges
      end
    end

    def validate_standard_ranges
      if after_or_equal_min_date
        add_error(I18n.t("#{translation_prefix}.date_after_or_equal_to"))
      elsif before_or_equal_to_submitt_date
        add_error(I18n.t("#{translation_prefix}.before_submit"))
      elsif three_months_check
        add_error(I18n.t("#{translation_prefix}.three_months"))
      end
    end

    # IAC applications may be received before they were submitted,
    # but no more than 365 days before
    def validate_iac_ranges
      if more_than_year_before_submitted
        add_error(I18n.t("#{translation_prefix}.iac_before_submit"))
      elsif three_months_check
        add_error(I18n.t("#{translation_prefix}.three_months"))
      end
    end

    def parse_string_date
      Date.parse(@date_received_value)
    rescue StandardError
      add_error(I18n.t("#{translation_prefix}.not_a_date"))
    end

    def add_error(message)
      @validate_record.errors.add(:date_received, message)
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

    def after_or_equal_min_date
      @date_received_value < @validate_record.created_at.to_date
    end

    def before_tomorrow
      tomorrow <= @date_received_value
    end

    def before_or_equal_to_submitt_date
      true if @date_received_value < submitted_date
    end

    def three_months_check
      return false if @validate_record.discretion_applied
      (@date_received_value - 3.months) > submitted_date
    end

    def more_than_year_before_submitted
      @date_received_value < (submitted_date - 365.days)
    end

    delegate :iac_jurisdiction?, to: :@validate_record

    def translation_prefix
      '.activemodel.errors.models.forms/online_application.attributes.date_received'
    end

  end
end
