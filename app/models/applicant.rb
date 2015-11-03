class Applicant < ActiveRecord::Base
  belongs_to :application, required: true

  before_validation :format_ni_number

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true

  def age
    @now = Time.zone.now.utc.to_date
    @now.year - date_of_birth.year - compare_months
  end

  def full_name
    [title, first_name, last_name].select(&:present?).join(' ')
  end

  private

  def compare_months
    current_month_past_date_of_birth_month || current_day_past_date_of_birth_day ? 0 : 1
  end

  def current_month_past_date_of_birth_month
    @now.month > date_of_birth.month
  end

  def current_day_past_date_of_birth_day
    @now.month == date_of_birth.month && @now.day >= date_of_birth.day
  end

  def format_ni_number
    ni_number.gsub!(' ', '') && ni_number.upcase! unless ni_number.nil?
  end
end
