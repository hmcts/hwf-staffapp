module DataFieldFormattable
  extend ActiveSupport::Concern

  # These methods are included after ActiveModel::Attributes to override the attribute getters
  # They provide computed values from the date attribute when the component attribute is nil
  included do
    # Override the day/month/year getters to fall back to date component values
    def day_date_received
      read_date_component_or_derive(:day_date_received) { date_received&.day }
    end

    def month_date_received
      read_date_component_or_derive(:month_date_received) { date_received&.month }
    end

    def year_date_received
      read_date_component_or_derive(:year_date_received) { date_received&.year }
    end

    def day_date_of_death
      read_date_component_or_derive(:day_date_of_death) { date_of_death&.day }
    end

    def month_date_of_death
      read_date_component_or_derive(:month_date_of_death) { date_of_death&.month }
    end

    def year_date_of_death
      read_date_component_or_derive(:year_date_of_death) { date_of_death&.year }
    end

    def day_date_fee_paid
      read_date_component_or_derive(:day_date_fee_paid) { date_fee_paid&.day }
    end

    def month_date_fee_paid
      read_date_component_or_derive(:month_date_fee_paid) { date_fee_paid&.month }
    end

    def year_date_fee_paid
      read_date_component_or_derive(:year_date_fee_paid) { date_fee_paid&.year }
    end

    private

    def read_date_component_or_derive(attr_name, &fallback)
      return nil unless respond_to?(:attributes)
      value = attributes[attr_name.to_s]
      value.nil? ? fallback.call : value
    end
  end

  def format_the_dates?(date_attr_name)
    date = send(date_attr_name.to_s)
    day = send(:"day_#{date_attr_name}")
    month = send(:"month_#{date_attr_name}")
    year = send(:"year_#{date_attr_name}")

    !(day.blank? && month.blank? && year.blank? && date.present?)
  end

  def format_dates(date_attr_name)
    send(:"#{date_attr_name}=", concat_dates(date_attr_name).to_date)
  rescue ArgumentError
    send(:"#{date_attr_name}=", concat_dates(date_attr_name))
  end

  def concat_dates(date_attr_name)
    day = send(:"day_#{date_attr_name}")
    month = send(:"month_#{date_attr_name}")
    year = send(:"year_#{date_attr_name}")
    return '' if day.blank? || month.blank? || year.blank?

    "#{day}/#{month}/#{year}"
  end

  def format_probate
    return if probate
    self.date_of_death = nil
    self.deceased_name = nil
  end

end
