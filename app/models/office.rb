class Office < ActiveRecord::Base
  has_many :users

  scope :sorted, -> {  all.order(:name) }
  scope :non_digital, -> { where.not(name: 'Digital') }

  validates :name, presence: true

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
