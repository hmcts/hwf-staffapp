class Application < ActiveRecord::Base # rubocop:disable ClassLength

  belongs_to :jurisdiction

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

  # Step 2 - Application details validation
  with_options if: :active_or_application_details? do
    validates :fee, :jurisdiction_id, presence: true
    validates :fee, numericality: { allow_blank: true }
    validates :date_received, date: {
      after: proc { Time.zone.today - 3.months },
      before: proc { Time.zone.today + 1.day }
    }
    with_options if: :probate? do
      validates :deceased_name, presence: true
      validates :date_of_death, date: {
        before: proc { Time.zone.today + 1.day }
      }

    end
    with_options if: :refund? do
      validates :date_fee_paid, date: {
        after: proc { Time.zone.today - 3.months },
        before: proc { Time.zone.today + 1.day }
      }
    end
  end
  # End step 2 validation

  # Step 3 - Savings and investments validation
  with_options if: :active_or_savings_investments? do
    validates :threshold_exceeded, inclusion: { in: [true, false] }
    validates :over_61, inclusion: { in: [true, false] }, if: :threshold_exceeded
    validates :over_61, inclusion: { in: [nil] }, unless: :threshold_exceeded
  end
  # End step 3 validation

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

  def fee=(val)
    super
    if known_over_61?
      self.threshold = 16000
    else
      self.threshold = val.to_i <= 1000 ? 3000 : 4000
    end
  end

  def threshold_exceeded=(val)
    super
    self.over_61 = nil unless val == true
  end

  def savings_investment_result?
    result = false
    if threshold_exceeded == false || (threshold_exceeded && over_61 == false)
      result = true
    end
    result
  end

  def full_name
    [title, first_name, last_name].join(' ')
  end

  def known_over_61?
    applicant_age >= 61
  end

  def applicant_age
    now = Time.zone.now.utc.to_date
    now.year - date_of_birth.year - (date_of_birth.to_date.change(year: now.year) > now ? 1 : 0)
  end

  private

  def active?
    status == 'active'
  end

  def active_or_personal_information?
    status.to_s.include?('personal_information') || active?
  end

  def active_or_application_details?
    status.to_s.include?('application_details') || active?
  end

  def active_or_savings_investments?
    status.to_s.include?('savings_investments') || active?
  end

  def active_or_summary?
    status.to_s.include?('summary') || active?
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
