class Application < ActiveRecord::Base

  MAX_AGE = 120
  MIN_AGE = 16

  # Step 1 - Personal detail validation
  with_options if: :active_or_personal_information? do
    validates :last_name, presence: true
    validates :married, inclusion: { in: [true, false] }
    validates :last_name, length: { minimum: 2 }, allow_blank: true
    validates :date_of_birth, date: true
    validate :dob_age_valid?
  end

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true
  # End step 1 validation

  def ni_number=(val)
    if val.nil?
      self[:ni_number] = nil
    else
      self[:ni_number] = val.upcase if val.present?
    end
  end

  def ni_number_display
    unless self[:ni_number].nil?
      self[:ni_number].gsub(/(.{2})/, '\1 ')
    end
  end

  def full_name
    [title, first_name, last_name].join(' ')
  end

  private

  def active?
    status == 'active'
  end

  def active_or_personal_information?
    status.to_s.include?('personal_information') || active?
  end

  def active_or_application_details?
    status.include?('application_details') || active?
  end

  def active_or_summary?
    status.include?('summary') || active?
  end

  def dob_age_valid?
    errors.add(:date_of_birth, "can't contain non numbers") if date_of_birth =~ /a-zA-Z/
    validate_dob_maximum unless date_of_birth.blank?
    validate_dob_minimum unless date_of_birth.blank?
  end

  def validate_dob_maximum
    if date_of_birth < Time.zone.today - MAX_AGE.years
      errors.add(
        :date_of_birth,
        I18n.t('activerecord.attributes.dwp_check.dob_too_old', max_age: MAX_AGE)
      )
    end
  end

  def validate_dob_minimum
    if date_of_birth > Time.zone.today - MIN_AGE.years
      errors.add(
        :date_of_birth,
        I18n.t('activerecord.attributes.dwp_check.dob_too_young', min_age: MIN_AGE)
      )
    end
  end
end
