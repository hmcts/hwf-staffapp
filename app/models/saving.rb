class Saving < ActiveRecord::Base
  belongs_to :application, optional: false, inverse_of: :saving

  alias_attribute :over_66, :over_61
end
