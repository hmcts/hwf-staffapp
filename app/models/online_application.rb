class OnlineApplication < ActiveRecord::Base
  belongs_to :jurisdiction

  validates :ni_number, :date_of_birth, :first_name, :last_name, :address,
    :postcode, presence: true
  validates :married, :threshold_exceeded, :benefits, :refund, :probate, :email_contact,
    :phone_contact, :post_contact, :feedback_opt_in, inclusion: [true, false]
  validates :reference, uniqueness: true

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end
end
