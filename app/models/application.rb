class Application < ActiveRecord::Base
  # paranoia gem
  acts_as_paranoid column: :purged, sentinel_value: false
  visitable :ahoy_visit

  include PgSearch::Model
  include ApplicationCheckable


  INCOME_PERIOD = { last_month: 'last_month', average: 'average' }.freeze

  serialize :income_kind, coder: YAML
  serialize :children_age_band, coder: YAML

  self.per_page = 25

  pg_search_scope :extended_search, against: [:reference], associated_against: {
    detail: [:case_number],
    applicant: [:ni_number]
  }

  pg_search_scope :name_search, associated_against: {
    applicant: [:first_name, :last_name]
  }

  has_paper_trail

  belongs_to :user, -> { with_deleted }
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :deleted_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :office, optional: true
  belongs_to :business_entity, optional: true
  belongs_to :online_application, optional: true
  has_many :benefit_checks, as: :applicationable, dependent: :destroy
  has_one :applicant, dependent: :destroy
  has_one :detail, inverse_of: :application, dependent: :destroy
  has_one :saving, inverse_of: :application, dependent: :destroy
  has_one :evidence_check, required: false, dependent: :destroy
  has_one :part_payment, required: false, dependent: :destroy
  has_one :benefit_override, required: false, dependent: :destroy
  has_one :decision_override, required: false, dependent: :destroy
  has_one :representative, dependent: :destroy
  has_many :dev_notes, as: :notable, dependent: :destroy

  scope :with_evidence_check_for_ni_number, (lambda do |ni_number|
    Application.where(state: states[:waiting_for_evidence]).
      joins(:evidence_check).
      joins(:applicant).where(applicants: { ni_number: ni_number })
  end)

  scope :with_evidence_check_for_ho_number, (lambda do |ho_number|
    Application.where(state: states[:waiting_for_evidence]).
      joins(:evidence_check).
      joins(:applicant).where(applicants: { ho_number: ho_number })
  end)

  scope :except_created, -> { where.not(state: 0) }
  scope :given_office_only, lambda { |office_id|
    where(office_id: office_id)
  }

  enum :state, {
    created: 0,
    waiting_for_evidence: 1,
    waiting_for_part_payment: 2,
    processed: 3,
    deleted: 4
  }

  validates :reference, uniqueness: true, allow_blank: true

  def last_benefit_check
    benefit_checks.where.not(benefits_valid: nil).where.not(dwp_result: nil).order(:id).last
  end

  def self.sort_received(sort_string)
    return 'details.date_received asc' if sort_string == 'received_asc'
    'details.date_received desc'
  end

  def self.sort_processed(sort_string)
    return 'completed_at asc' if sort_string == 'processed_asc'
    'completed_at desc'
  end

  def self.sort_fee(sort_string)
    return 'details.fee asc' if sort_string == 'fee_asc'
    'details.fee desc'
  end

  def payment_expires_at
    days = Settings.payment.expires_in_days
    Time.zone.today + days
  end

  def failed_because_dwp_error?
    return false if last_benefit_check.blank?
    bad_request? || benefit_check_unavailable?
  end

  delegate :bad_request?, to: :last_benefit_check

  def benefit_check_unavailable?
    return false if last_benefit_check.error_message.blank?
    last_benefit_check.dwp_result == 'Server unavailable' &&
      last_benefit_check.error_message.include?('The benefits checker is not available at the moment')
  end

  def benefit_check_with_error_message?
    last_benefit_check&.error_message.present?
  end

  def allow_benefit_check_override?
    benefit_check_with_error_message? || BenefitCheck::BENEFIT_CHECK_NO_VALUES.include?(last_benefit_check&.dwp_result)
  end

  def digital?
    medium == 'digital'
  end

  def income_period_three_months_average?
    income_period == INCOME_PERIOD[:average]
  end

  def income_period_last_month?
    income_period == INCOME_PERIOD[:last_month]
  end

end
