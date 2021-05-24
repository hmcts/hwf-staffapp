class HmrcCheck < ActiveRecord::Base
  belongs_to :application, optional: false

  serialize :address
  serialize :employment
  serialize :income
  serialize :tax_credit
end
