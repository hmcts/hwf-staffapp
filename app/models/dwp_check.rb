class DwpCheck < ActiveRecord::Base

  include CommonScopes

  belongs_to :created_by, class_name: 'User'

  before_create :generate_unique_number

  validates :last_name, :dob, :ni_number, presence: true
  validates :last_name, length: { minimum: 2 }, allow_blank: true

  validate :date_to_check_must_be_valid
  validate :date_of_birth_must_be_valid

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/,
    message: 'is not valid'
  }, allow_blank: true

  scope :by_office, lambda { |office_id|
    joins('left outer join users on dwp_checks.created_by_id = users.id').
      where('users.office_id = ?', office_id)
  }
  scope :by_office_grouped_by_type, lambda { |office_id|
    joins('left outer join users on dwp_checks.created_by_id = users.id').
      where('users.office_id = ?', office_id).
      group(:dwp_result).
      order('length(dwp_result)')
  }

  def date_to_check_must_be_valid
    if date_to_check.present? && (
      date_to_check > Date.today ||
      date_to_check < Date.today - 3.months
    )
      errors.add(:date_to_check, 'must be in the last 3 months')
    end
  end

  def date_of_birth_must_be_valid
    if dob.present? && dob >= Date.today
      errors.add(:dob, 'must be before today')
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

end
