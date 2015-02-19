class DwpCheck < ActiveRecord::Base

  belongs_to :created_by, class_name: 'User'

  before_create :generate_unique_number

  validates :last_name, :dob, :ni_number, presence: true
  validates :ni_number,
              format: {
                with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/,
                message: 'is not valid'}

  def unique_number
    self[:unique_number].scan(/.{1,4}/).join('-')
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
    begin
      new_uid = SecureRandom.hex(4)
    end while DwpCheck.find_by(unique_number: new_uid).present?
    self.unique_number = new_uid
  end

end
