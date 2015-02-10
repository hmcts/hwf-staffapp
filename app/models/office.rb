class Office < ActiveRecord::Base

  scope :sorted, -> {  all.order(:name) }

end
