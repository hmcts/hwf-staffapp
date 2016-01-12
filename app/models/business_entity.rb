class BusinessEntity < ActiveRecord::Base
  belongs_to :office
  belongs_to :jurisdiction

  validates :office, :jurisdiction, :code, :name, :valid_from, presence: true

  validates :valid_to, date: {
    after: :valid_from, allow_blank: true
  }
end
