class BenefitCheck < ActiveRecord::Base
  belongs_to :application

  include CommonScopes

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
end
