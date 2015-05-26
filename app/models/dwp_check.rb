class DwpCheck < ActiveRecord::Base

  MAX_AGE = 120
  MIN_AGE = 16

  include CommonScopes

  belongs_to :created_by, class_name: 'User'
  belongs_to :office

  before_create :generate_unique_number
  after_create :generate_api_token

  before_validation :strip_whitespace

  validates :last_name, :ni_number, :office_id, presence: true
  validates :last_name, length: { minimum: 2 }, allow_blank: true

  validates :dob, date: true, presence: true
  validate :dob_age_valid?

  validate :date_to_check_must_be_valid

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true

  scope :non_digital, -> { joins(:office).where('offices.name != ?', 'Digital') }

  scope :by_office, lambda { |office_id|
    joins('left outer join users on dwp_checks.created_by_id = users.id').
      where('dwp_checks.office_id = ?', office_id)
  }
  scope :by_office_grouped_by_type, lambda { |office_id|
    joins('left outer join users on dwp_checks.created_by_id = users.id').
      where('dwp_checks.office_id = ?', office_id).
      group(:dwp_result).
      order('length(dwp_result)')
  }
  def strip_whitespace
    ni_number && ni_number.strip!
  end

  def date_to_check_must_be_valid
    if date_to_check.present?
      if within_valid_range?
        errors.add(:date_to_check, 'must be in the last 3 months')
      end

      begin
        Date.parse "#{date_to_check}"
      rescue ArgumentError
        errors.add(:date_to_check, 'ffffffffff')
      end
    end
  end

  def ni_number=(val)
    if val.nil?
      self[:ni_number] = nil
    else
      self[:ni_number] = val.upcase if val.present?
    end
  end

private

  def generate_unique_number
    new_uid = ''
    loop do
      new_uid = SecureRandom.hex(4).scan(/.{1,4}/).join('-')
      break if DwpCheck.find_by(unique_number: new_uid).nil?
    end
    self.unique_number = new_uid
  end

  def generate_api_token
    short_name = created_by.name.gsub(' ', '').downcase.truncate(27)
    self.our_api_token = "#{short_name}@#{created_at.strftime('%y%m%d%H%M%S')}.#{unique_number}"
    self.save!
  end

  def before_today?
    date_to_check > Date.today
  end

  def within_three_months_in_the_past?
    date_to_check < Date.today - 3.months
  end

  def within_valid_range?
    before_today? || within_three_months_in_the_past?
  end

  def dob_age_valid?
    errors.add(:dob, "can't contain non numbers") if dob =~ /a-zA-Z/
    validate_dob_maximum unless dob.blank?
    validate_dob_minimum unless dob.blank?
  end

  def validate_dob_maximum
    if dob < Date.today - MAX_AGE.years
      errors.add(:dob, "can't be over #{MAX_AGE} years old")
    end
  end

  def validate_dob_minimum
    if dob > Date.today - MIN_AGE.years
      errors.add(:dob, "can't be under #{MIN_AGE} years old")
    end
  end
end
