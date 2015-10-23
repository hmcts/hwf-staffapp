class Applicant < ActiveRecord::Base
  belongs_to :application, required: true

  before_validation :format_ni_number

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true

  private

  def format_ni_number
    ni_number.gsub!(' ', '') && ni_number.upcase! unless ni_number.nil?
  end
end
