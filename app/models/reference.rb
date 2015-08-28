class Reference < ActiveRecord::Base
  belongs_to :application

  validates :reference, presence: true
  validate :reference_format

  private

  def reference_format
    unless reference.blank?
      check_reference_format
      check_reference_year
      check_counter
    end
  end

  def check_reference_format
    unless reference =~ /[A-Z]{2}[0-9]{3}-[0-9]{2}-[0-9]+/
      errors.add(:reference, 'invalid format')
    end
  end

  def check_reference_year
    provided_reference_year = reference.split('-')[1]
    errors.add(:reference, 'Invalid year') if current_year != provided_reference_year
  end

  def check_counter
    reference_parts = reference.split('-')
    entity_code = reference_parts.first
    provided_counter = reference_parts.last
    count = Reference.where("reference like ?", "#{entity_code}-#{current_year}-%").count
    unless (count.to_i + 1) == provided_counter.to_i
      errors.add(:reference, 'invalid counter')
    end
  end

  def current_year
    Time.zone.now.strftime('%y')
  end
end
