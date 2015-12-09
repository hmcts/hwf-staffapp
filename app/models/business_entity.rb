class BusinessEntity < ActiveRecord::Base
  belongs_to :office
  belongs_to :jurisdiction

  validates :office, :jurisdiction, :code, :name, presence: true
end
