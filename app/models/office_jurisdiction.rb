class OfficeJurisdiction < ActiveRecord::Base
  belongs_to :office
  belongs_to :jurisdiction
end
