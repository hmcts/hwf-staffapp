class OnlineApplication < ActiveRecord::Base
  serialize :income_kind

  belongs_to :jurisdiction, optional: true

  validates :date_of_birth, :first_name, :last_name, :address,
            :postcode, presence: true
  validates :married, :min_threshold_exceeded, :benefits, :refund, :email_contact,
            :phone_contact, :post_contact, :feedback_opt_in, inclusion: [true, false]
  validates :reference, uniqueness: true

  validates :ni_number, presence: true, if: ->(app) { app.ho_number.blank? }

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end

  def applicant
    Applicant.new(online_applicant_attributes)
  end

  # FIXME: This is here temporarily until we can refactor view models
  def detail
    self
  end

  def processed?
    linked_application.present? && !linked_application.created?
  end

  def linked_application
    Application.find_by(online_application: self)
  end

  private

  def online_applicant_attributes
    fields = [:title, :first_name, :last_name, :date_of_birth, :ni_number, :ho_number, :married]
    fields.map { |field| [field, send(field)] }.to_h
  end

end
