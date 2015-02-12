class Office < ActiveRecord::Base

  scope :sorted, -> {  all.order(:name) }


  validates :name, presence: true

end
