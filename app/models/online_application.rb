class OnlineApplication < ActiveRecord::Base
  validates :children, :ni_number, :date_of_birth, :first_name, :last_name, :address,
    :postcode, presence: true
  validates :married, :threshold_exceeded, :benefits, :refund, :probate, :email_contact,
    :phone_contact, :post_contact, inclusion: [true, false]
  validates :reference, uniqueness: true

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end
end
