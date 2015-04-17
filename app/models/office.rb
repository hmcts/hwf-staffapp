class Office < ActiveRecord::Base
  has_many :users

  scope :sorted, -> {  all.order(:name) }

  validates :name, presence: true

end
