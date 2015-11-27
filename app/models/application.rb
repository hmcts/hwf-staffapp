class Application < ActiveRecord::Base

  belongs_to :user, -> { with_deleted }
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User'
  belongs_to :office
  has_many :benefit_checks
  has_one :applicant
  has_one :detail, inverse_of: :application
  has_one :evidence_check, required: false
  has_one :part_payment, required: false
  has_one :benefit_override, required: false

  validates :reference, presence: true, uniqueness: true

  # Fixme remove this delegation methods when all tests are clean
  APPLICANT_GETTERS = %i[
    title first_name last_name full_name date_of_birth ni_number married married?
  ]
  APPLICANT_SETTERS = %i[title= first_name= last_name= date_of_birth= ni_number= married=]
  delegate(*APPLICANT_GETTERS, to: :applicant)
  delegate(*APPLICANT_SETTERS, to: :applicant)
  delegate(:age, to: :applicant, prefix: true)

  DETAIL_GETTERS = %i[
    fee jurisdiction date_received form_name case_number probate probate? deceased_name
    date_of_death refund refund? date_fee_paid emergency_reason
  ]
  DETAIL_SETTERS = %i[
    fee= jurisdiction= date_received= form_name= case_number= probate= deceased_name=
    date_of_death= refund= date_fee_paid= emergency_reason=
  ]
  delegate(*DETAIL_GETTERS, to: :detail)
  delegate(*DETAIL_SETTERS, to: :detail)

  MAX_AGE = 120
  MIN_AGE = 16

  def children=(val)
    self[:children] = dependents? ? val : 0
  end

  # FIXME: Remove the threshold field from db as it's read only now
  def threshold
    applicant_over_61? ? 16000 : FeeThreshold.new(fee).band
  end

  def threshold_exceeded=(val)
    super
    self.partner_over_61 = nil unless threshold_exceeded?
    if threshold_exceeded? && (!partner_over_61 || applicant_over_61?)
      self.application_type = 'none'
      self.outcome = 'none'
      self.dependents = nil
    end
  end

  def high_threshold_exceeded=(val)
    super
    if high_threshold_exceeded?
      self.application_type = 'none'
      self.outcome = 'none'
      self.dependents = nil
    else
      self.application_type = nil
      self.outcome = nil
    end
  end

  def savings_investment_valid?
    result = false
    if threshold_exceeded == false ||
       (threshold_exceeded && (partner_over_61 && high_threshold_exceeded == false))
      result = true
    end
    result
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
