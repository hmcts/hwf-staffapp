class DwpCheck < ActiveRecord::Base
  validates :last_name, :dob, :ni_number, presence: true
  validates :ni_number,
              format: {
                with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/,
                message: 'is not a valid NI number'}

end
