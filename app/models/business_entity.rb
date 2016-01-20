class BusinessEntity < ActiveRecord::Base
  belongs_to :office
  belongs_to :jurisdiction

  validates :office, :jurisdiction, :code, :name, :valid_from, presence: true

  validates :valid_to, date: {
    after: :valid_from, allow_blank: true
  }

  def self.current_for(office, jurisdiction)
    BusinessEntity.find_by(office: office, jurisdiction: jurisdiction, valid_to: nil)
  end
end
