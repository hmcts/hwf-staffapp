class EvidenceCheckFlag < ActiveRecord::Base
  validates :ni_number, presence: true
  validates :ni_number, uniqueness: { scope: :active }, if: :active?
end
