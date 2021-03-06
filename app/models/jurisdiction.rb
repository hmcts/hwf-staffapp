class Jurisdiction < ActiveRecord::Base

  has_many :office_jurisdictions
  has_many :offices, through: :office_jurisdictions
  has_many :business_entities

  validates :name, uniqueness: true, presence: true
  validates :abbr, uniqueness: { allow_nil: true }

  scope :available_for_office, lambda { |office|
    joins(:business_entities).
      where(business_entities: { office: office }).
      where(business_entities: { valid_to: nil })
  }

  def display
    self.abbr ||= name
  end

  def display_full
    result = name
    result.concat(" (#{abbr})") if abbr.present?
    result
  end
end
