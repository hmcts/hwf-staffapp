class User < ActiveRecord::Base
  belongs_to :office

  ROLES = %w[admin user]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable, :rememberable and :omniauthable
  devise :database_authenticatable,
    :recoverable,
    :trackable,
    :validatable,
    :invitable

  scope :sorted_by_email, -> {  all.order(:email) }

  email_regex = /\A([^@\s]+)@(hmcts\.gsi|digital\.justice)\.gov\.uk\z/i
  validates :role, :name, presence: true
  validates :email, format: {
    with: email_regex,
    on: [:create, :update],
    allow_nil: true,
    message: I18n.t('dictionary.invalid_email', email: Settings.mail_tech_support)
  }
  validates :role, inclusion: {
    in: ROLES,
    message: "%{value} is not a valid role",
    allow_nil: true
  }

  def admin?
    role == 'admin'
  end
end
