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
  email_message =  <<-END.gsub(/^\s+\|/, '').gsub(/\n/, '')
    |you’re not able to create an account with this email
    | address. Only 'name@hmcts.gsi.gov.uk' emails can be used. For more help,
    | contact us via #{Settings.mail_tech_support}
  END

  validates :email, format: { with: email_regex, on: :create, message: email_message }
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
