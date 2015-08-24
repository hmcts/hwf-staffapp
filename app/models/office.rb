class Office < ActiveRecord::Base
  has_many :users
  has_many :office_jurisdictions
  has_many :jurisdictions, through: :office_jurisdictions

  scope :sorted, -> {  all.order(:name) }
  scope :non_digital, -> { where.not(name: 'Digital') }

  validates :name, presence: true, uniqueness: true
  validates :entity_code, presence: true, uniqueness: true

  def managers
    users.where(office_id: id, role: 'manager')
  end

  def managers_email
    return 'a manager' unless managers.present?
    emails = []
    managers.each do |m|
      emails << "<a href=\"mailto:#{m.email}\">#{m.name}</a>".html_safe
    end
    emails.join(', ')
  end
end
