class Saving < ActiveRecord::Base
  belongs_to :application, optional: false, inverse_of: :saving
end
