class Jurisdiction < ActiveRecord::Base

  has_many :office_jurisdictions
  has_many :offices, through: :office_jurisdictions

  validates :name, uniqueness: true, presence: true
  validates :abbr, uniqueness: { allow_nil: true }

  def display
    self.abbr ||= name
  end

  def display_full
    result = name
    result.concat(" (#{abbr})") unless abbr.blank?
    result
  end
end
