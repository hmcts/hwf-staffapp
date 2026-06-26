class BenefitCheck < ActiveRecord::Base
  belongs_to :applicationable, polymorphic: true
  belongs_to :user, optional: true
  has_many :dev_notes, as: :notable, dependent: :destroy
  has_many :dwp_api_calls, dependent: :destroy
  BENEFIT_CHECK_NO_VALUES = ['No', 'Undetermined', 'Deceased', 'Deleted', 'Superseded', ''].freeze

  # A valid DWP answer - needs no rerun and is not an outage.
  VALID_DWP_RESULTS = ['Yes', 'No'].freeze

  # Genuine DWP answers that are never an outage and never a rerun candidate.
  # Undetermined means DWP responded but couldn't determine entitlement, so a
  # rerun cannot change it - it is excluded up front in SQL and by the predicate.
  NON_OUTAGE_RESULTS = (VALID_DWP_RESULTS + ['Undetermined']).freeze

  # BadRequest messages naming a field as invalid/missing are the applicant's
  # data problem, not a DWP outage - a rerun cannot fix them.
  DWP_VALIDATION_ERROR_PATTERNS = ['is invalid', 'is not valid', 'is missing'].freeze

  include CommonScopes

  # True when a check failed because of DWP itself (an outage), as opposed to a
  # genuine DWP answer (Yes/No/Undetermined) or an applicant-data problem. The
  # DWP monitor counts these and the rerun job retries them, so both share this
  # single definition. Undetermined is a valid DWP answer (it couldn't determine
  # entitlement), not an outage, so it never counts.
  def self.dwp_outage_failure?(dwp_result, error_message)
    result = dwp_result.to_s.strip
    return false if NON_OUTAGE_RESULTS.any? { |answer| result.casecmp?(answer) }
    return false if result == 'BadRequest' && dwp_validation_error?(error_message)

    true
  end

  def self.dwp_validation_error?(error_message)
    return false if error_message.blank?

    DWP_VALIDATION_ERROR_PATTERNS.any? { |pattern| error_message.include?(pattern) }
  end

  def dwp_outage_failure?
    self.class.dwp_outage_failure?(dwp_result, error_message)
  end

  scope :by_office, lambda { |office_id|
    joins('LEFT JOIN applications ON benefit_checks.applicationable_id = applications.id').
      where(applications: { office_id: office_id }, benefit_checks: { applicationable_type: 'Application' })
  }

  scope :non_digital, lambda {
    joins('LEFT JOIN applications ON benefit_checks.applicationable_id = applications.id').
      joins('LEFT JOIN offices ON applications.office_id = offices.id').
      where.not(offices: { name: 'Digital' }).where(benefit_checks: { applicationable_type: 'Application' })
  }

  scope :by_office_grouped_by_type, lambda { |office_id|
    joins('LEFT JOIN applications ON benefit_checks.applicationable_id = applications.id').
      where(applications: { office_id: office_id }, benefit_checks: { applicationable_type: 'Application' }).
      group(:dwp_result).
      order(Arel.sql('length(dwp_result)'))
  }

  def outcome
    dwp_result == 'Yes' ? 'full' : 'none'
  end

  def dwp_error?
    bad_request? || benefit_check_unavailable?
  end

  def bad_request?
    dwp_result == 'BadRequest' &&
      (error_message.include?('LSCBC') || error_message.include?('Service unavailable'))
  end

  def benefit_check_unavailable?
    return false if error_message.blank?
    dwp_result == 'Server unavailable' &&
      error_message.include?('The benefits checker is not available at the moment')
  end

  def passed?
    dwp_result == 'Yes'
  end
end
