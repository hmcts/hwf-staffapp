class DwpApiCall < ActiveRecord::Base
  belongs_to :benefit_check

  validates :endpoint_name, presence: true
end
