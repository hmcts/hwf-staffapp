class Detail < ActiveRecord::Base
  belongs_to :application, required: true
end
