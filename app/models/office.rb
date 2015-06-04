class Office < ActiveRecord::Base
  has_many :users

  scope :sorted, -> {  all.order(:name) }
  scope :non_digital, -> { where.not(name: 'Digital') }

  validates :name, presence: true

  def managers
    users.where(office_id: id, role: 'manager')
  end

end
