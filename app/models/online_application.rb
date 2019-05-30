class OnlineApplication < ActiveRecord::Base
  belongs_to :jurisdiction, optional: true

  validates :ni_number, :date_of_birth, :first_name, :last_name, :address,
            :postcode, presence: true
  validates :married, :min_threshold_exceeded, :benefits, :refund, :email_contact,
            :phone_contact, :post_contact, :feedback_opt_in, inclusion: [true, false]
  validates :reference, uniqueness: true

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end

  # FIXME: This is here temporarily until we can refactor view models
  def applicant
    self
  end

  # FIXME: This is here temporarily until we can refactor view models
  def detail
    self
  end

  def processed?
    linked_application.present?
  end

  def linked_application
    Application.find_by(online_application: self)
  end
end
