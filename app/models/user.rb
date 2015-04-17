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

  validates :email, format: Devise.email_regexp
  validates :role, :name, presence: true
  validates :role, inclusion: {
    in: ROLES,
    message: "%{value} is not a valid role",
    allow_nil: true
  }

  def admin?
    role == 'admin'
  end
end
