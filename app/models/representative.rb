class Representative < ApplicationRecord
  belongs_to :application, dependent: :destroy
end
