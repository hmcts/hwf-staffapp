class OnlineApplication < ActiveRecord::Base
  validates :married, :threshold_exceeded, :benefits, :children, :refund, :probate, :ni_number,
    :date_of_birth, :first_name, :last_name, :address, :postcode, :email_contact,
    :phone_contact, :post_contact, presence: true
  validates :reference, uniqueness: true
end
