class Reference < ActiveRecord::Base
  belongs_to :application

  validates :reference, presence: true
end
