class HmrcToken < ActiveRecord::Base
  before_create :only_one_record_allowed

end