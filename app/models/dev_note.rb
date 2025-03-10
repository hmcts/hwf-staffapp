class DevNote < ApplicationRecord
  belongs_to :notable, polymorphic: true
end
