class User < ActiveRecord::Base
  # paranoia gem
  acts_as_paranoid

  belongs_to :office
  belongs_to :jurisdiction, optional: true
  has_many :applications
  has_many :benefit_checks
  has_many :export_file_storages

  ROLES = ['user', 'manager', 'admin', 'mi', 'reader'].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable, :rememberable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :trackable,
         :validatable,
         :invitable,
         :registerable,
         :confirmable,
         :timeoutable,
         :session_limitable

  scope :active, -> { where('current_sign_in_at >= ?', inactivate_date) }
  scope :inactive, (lambda do
    where('current_sign_in_at < ? OR current_sign_in_at IS NULL', inactivate_date)
  end)

  scope :sorted_by_email, -> { order(:email) }

  scope :by_office, ->(office_id) { where(office_id: office_id) }
  email_regex = /\A([^@\s]+)@(((justice|hmcourts-service|hmcts)\.gsi|digital\.justice|justice)\.gov\.uk|hmcts\.net)\z/i

  validates :role, :name, presence: true
  validates :email, format: {
    with: email_regex,
    on: [:create, :update],
    allow_nil: true,
    message: :invalid_email, email: Settings.mail.tech_support
  }
  validates :role, inclusion: {
    in: ROLES,
    message: I18n.t('role.inclusions'),
    allow_nil: true
  }
  validate :jurisdiction_is_valid

  before_create :skip_confirmation!

  def elevated?
    admin? || manager?
  end

  def staff?
    role == 'user'
  end

  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  def mi?
    role == 'mi'
  end

  def reader?
    role == 'reader'
  end

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  def activity_flag
    return :active if current_sign_in_at && current_sign_in_at >= self.class.inactivate_date

    :inactive
  end

  def self.inactivate_date
    3.months.ago
  end

  private

  def jurisdiction_is_valid
    unless jurisdiction_id.nil? || Jurisdiction.exists?(jurisdiction_id)
      errors.add(:jurisdiction, 'Jurisdiction must exist')
    end
  end
end
