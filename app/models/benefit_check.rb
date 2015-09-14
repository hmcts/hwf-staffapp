class BenefitCheck < ActiveRecord::Base
  belongs_to :application

  scope :by_office, lambda { |office_id|
    joins(:application).
      where('applications.office_id = ?', office_id)
  }

  scope :non_digital, lambda {
    joins(:application).joins('LEFT OUTER JOIN offices ON applications.office_id = offices.id').
      where('offices.name != ?', 'Digital')
  }

  scope :by_office_grouped_by_type, lambda { |office_id|
    joins(:application).
      where('applications.office_id = ?', office_id).
      group(:dwp_result).
      order('length(dwp_result)')
  }

  scope :checks_by_day, lambda {
    group_by_day("applications.created_at", format: "%d %b %y").
      where("applications.created_at > ?", (Time.zone.today.-6.days)).count
  }

end
