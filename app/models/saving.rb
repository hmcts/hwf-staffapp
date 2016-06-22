class Saving < ActiveRecord::Base
  belongs_to :application, required: true, inverse_of: :saving
end
