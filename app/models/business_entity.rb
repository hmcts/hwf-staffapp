class BusinessEntity < ActiveRecord::Base
  belongs_to :office
  belongs_to :jurisdiction

  scope :exclude_hq_teams, lambda {
    joins(:office).where.not("offices.name IN ('Digital', 'HMCTS HQ Team ')")
  }

  validates :office, :jurisdiction, :be_code, :sop_code, :name, :valid_from, presence: true

  validates :valid_to, date: {
    after: :valid_from, allow_blank: true
  }

  def self.current_for(office, jurisdiction)
    BusinessEntity.find_by(office: office, jurisdiction: jurisdiction, valid_to: nil)
  end

  def code
    be_code
  end
end
