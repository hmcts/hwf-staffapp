class EvidenceCheckFlag < ActiveRecord::Base
  validates :reg_number, presence: true
  validates :reg_number, uniqueness: { scope: :active }, if: :active?
end
