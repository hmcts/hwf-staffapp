class Office < ActiveRecord::Base
  has_many :users
  has_many :applications
  has_many :office_jurisdictions
  has_many :jurisdictions, through: :office_jurisdictions
  has_many :business_entities

  scope :sorted, -> { all.order(:name) }
  scope :non_digital, -> { where.not(name: 'Digital') }

  validates :name, presence: true, uniqueness: true

  def managers
    users.where(office_id: id, role: 'manager')
  end

  def business_entities
    BusinessEntity.where(office_id: id).
      where('valid_to IS NULL').
      order(:jurisdiction_id)
  end
end
