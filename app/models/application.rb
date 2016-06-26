class Application < ActiveRecord::Base

  belongs_to :user, -> { with_deleted }
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User'
  belongs_to :deleted_by, -> { with_deleted }, class_name: 'User'
  belongs_to :office
  belongs_to :business_entity
  belongs_to :online_application
  has_many :benefit_checks
  has_one :applicant
  has_one :detail, inverse_of: :application
  has_one :saving, inverse_of: :application
  has_one :evidence_check, required: false
  has_one :part_payment, required: false
  has_one :benefit_override, required: false

  enum state: {
    created: 0,
    waiting_for_evidence: 1,
    waiting_for_part_payment: 2,
    processed: 3,
    deleted: 4
  }

  validates :reference, uniqueness: true, allow_blank: true

  DETAIL_GETTERS = %i[
    fee jurisdiction date_received form_name case_number probate probate? deceased_name
    date_of_death refund refund? date_fee_paid emergency_reason
  ].freeze
  DETAIL_SETTERS = %i[
    fee= jurisdiction= date_received= form_name= case_number= probate= deceased_name=
    date_of_death= refund= date_fee_paid= emergency_reason=
  ].freeze
  delegate(*DETAIL_GETTERS, to: :detail)
  delegate(*DETAIL_SETTERS, to: :detail)

  MAX_AGE = 120
  MIN_AGE = 16

  def children=(val)
    self[:children] = dependents? ? val : 0
  end

  def applicant_over_61?
    applicant.age >= 61
  end

  def check_high_threshold?
    partner_over_61? && !applicant_over_61?
  end

  def last_benefit_check
    benefit_checks.order(:id).last
  end
end
