class HmrcCheck < ActiveRecord::Base
  belongs_to :evidence_check, optional: false

  serialize :address
  serialize :employment
  serialize :income
  serialize :tax_credit
end
