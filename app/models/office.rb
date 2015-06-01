class Office < ActiveRecord::Base
  has_many :users

  scope :sorted, -> {  all.order(:name) }
  scope :non_digital, -> { where('name != ?', 'Digital') }

  validates :name, presence: true

end
