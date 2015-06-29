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

  validates :dob, date: true
  validate :dob_age_valid?

  validates :date_to_check, date: {
    allow_nil: true,
    after: proc { Time.zone.today - 3.months },
    before: proc { Time.zone.today + 1.day }
  }

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true

  scope :non_digital, -> { joins(:office).where('offices.name != ?', 'Digital') }

  scope :by_office, -> (office_id) { where('dwp_checks.office_id = ?', office_id) }

  scope :by_office_grouped_by_type, lambda { |office_id|
    joins('left outer join users on dwp_checks.created_by_id = users.id').
      where('dwp_checks.office_id = ?', office_id).
      group(:dwp_result).
      order('length(dwp_result)')
  }

  def strip_whitespace
    ni_number && ni_number.strip!
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

  def dob_age_valid?
    errors.add(:dob, "can't contain non numbers") if dob =~ /a-zA-Z/
    validate_dob_maximum unless dob.blank?
    validate_dob_minimum unless dob.blank?
  end

  def validate_dob_maximum
    if dob < Time.zone.today - MAX_AGE.years
      errors.add(:dob, I18n.t('activerecord.attributes.dwp_check.dob_too_old', max_age: MAX_AGE))
    end
  end

  def validate_dob_minimum
    if dob > Time.zone.today - MIN_AGE.years
      errors.add(:dob, I18n.t('activerecord.attributes.dwp_check.dob_too_young', min_age: MIN_AGE))
    end
  end
end
