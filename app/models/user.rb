class User < ActiveRecord::Base

  ROLES = %w[admin user]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable, 
          # :registerable,
          :recoverable, 
          # :rememberable, 
          :trackable, 
          :validatable,
          :invitable

  scope :sorted_by_email, -> {  all.order(:email) }

  validates_format_of :email, :with => Devise::email_regexp

  validates :role, presence: true
  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role", allow_nil: true }


  def admin?
    self.role == 'admin'
  end
end

