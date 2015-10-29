class Application < ActiveRecord::Base # rubocop:disable ClassLength

  belongs_to :user
  belongs_to :jurisdiction
  belongs_to :office
  has_many :benefit_checks
  has_one :applicant
  has_one :evidence_check, required: false
  has_one :payment, required: false
  has_one :benefit_override, required: false

  validates :reference, presence: true, uniqueness: true

  scope :evidencecheckable, lambda {
    where(benefits: false,
          application_type: 'income',
          emergency_reason: nil,
          application_outcome: %w[part full])
  }

  scope :waiting_for_evidence, lambda {
    includes(:evidence_check).
      references(:evidence_check).
      where('evidence_checks.completed_at IS NULL').
      where.not(evidence_checks: { id: nil }).
      order('evidence_checks.expires_at ASC')
  }

  scope :waiting_for_payment, lambda {
    includes(:payment).
      references(:payment).
      where('payments.completed_at IS NULL').
      where.not(payments: { id: nil }).
      order('payments.expires_at ASC')
  }

  # Fixme remove this delegation methods when all tests are clean
  APPLICANT_GETTERS = %i[title first_name last_name date_of_birth ni_number married married?]
  APPLICANT_SETTERS = %i[title= first_name= last_name= date_of_birth= ni_number= married=]
  delegate(*APPLICANT_GETTERS, to: :applicant)
  delegate(*APPLICANT_SETTERS, to: :applicant)
  delegate(:age, to: :applicant, prefix: true)

  MAX_AGE = 120
  MIN_AGE = 16

  after_save :run_auto_checks
  before_validation :nullify_blank_emergency_reason

  # Step 2 - Application details validation
  with_options if: proc { active_or_status_is? 'application_details' } do
    validates :fee, :jurisdiction_id, presence: true
    validates :fee, numericality: { allow_blank: true }
    validates :date_received, date: {
      after: proc { Time.zone.today - 3.months },
      before: proc { Time.zone.today + 1.day }
    }
    with_options if: :probate? do
      validates :deceased_name, presence: true
      validates :date_of_death, date: {
        before: proc { Time.zone.today + 1.day }
      }

    end
    with_options if: :refund? do
      validates :date_fee_paid, date: {
        after: proc { Time.zone.today - 3.months },
        before: proc { Time.zone.today + 1.day }
      }
    end
  end
  # End step 2 validation

  # Step 3 - Savings and investments validation
  with_options if: proc { active_or_status_is? 'savings_investments' } do
    validates :threshold_exceeded, inclusion: { in: [true, false] }
    validates :partner_over_61, inclusion: { in: [true, false] }, if: :threshold_exceeded
    validates :high_threshold_exceeded, inclusion: { in: [true, false] }, if: :check_high_threshold?
  end
  # End step 3 validation

  # Step 4 - Benefits
  with_options if: proc { active_or_status_is? 'benefits' } do
    validates :benefits, inclusion: { in: [true, false] }, if: :benefits_required?
  end
  # End step 4 validation

  # Step 5 - Income
  with_options if: proc { active_or_status_is? 'income' } do
    validates :dependents, inclusion: { in: [true, false] }, if: :income_required?
    validates :income, numericality: true, if: :income_required?
    validates :children, numericality: true, if: :income_children_required?
    validate :children_numbers, if: :income_required?
  end
  # End step 5 validation

  alias_attribute :outcome, :application_outcome

  def children=(val)
    self[:children] = dependents? ? val : 0
  end

  def ni_number_display
    ni_number.gsub(/(.{2})/, '\1 ') unless ni_number.nil?
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
      self.application_outcome = 'none'
      self.dependents = nil
    end
  end

  def high_threshold_exceeded=(val)
    super
    if high_threshold_exceeded?
      self.application_type = 'none'
      self.application_outcome = 'none'
      self.dependents = nil
    else
      self.application_type = nil
      self.application_outcome = nil
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

  def benefits=(val)
    super
    self.application_type = benefits? ? 'benefit' : 'income'
    self.dependents = nil if benefits?
    self.application_outcome = outcome_from_dwp_result if benefits? && last_benefit_check.present?
  end

  def full_name
    [title, first_name, last_name].join(' ')
  end

  def applicant_over_61?
    applicant.age >= 61
  end

  def check_high_threshold?
    partner_over_61? && !applicant_over_61?
  end

  def can_check_benefits?
    [
      last_name.present?,
      date_of_birth.present?,
      ni_number.present?,
      (date_received.present? || date_fee_paid.present?)
    ].all?
  end

  def last_benefit_check
    benefit_checks.order(:id).last
  end

  def evidence_check?
    !evidence_check.nil?
  end

  def payment?
    !payment.nil?
  end

  private

  def income_required?
    active_or_status_is?('income') & !benefits? && savings_investment_valid?
  end

  def income_children_required?
    income_required? && dependents?
  end

  def benefits_required?
    active_or_status_is?('benefits') && :savings_investment_valid?
  end

  def run_auto_checks
    run_benefit_check
    run_income_calculation
  end

  def children_numbers
    errors.add(
      :children,
      I18n.t('activerecord.errors.models.application.attributes.children.not_a_number')
    ) if dependents? && no_children?
  end

  def no_children?
    children_present? && children == 0
  end

  def children_present?
    children.present?
  end

  def run_benefit_check # rubocop:disable MethodLength
    if can_check_benefits? && new_benefit_check_needed?
      BenefitCheckService.new(
        benefit_checks.create(
          last_name: last_name,
          date_of_birth: date_of_birth,
          ni_number: ni_number,
          date_to_check: benefit_check_date,
          our_api_token: generate_api_token,
          parameter_hash: build_hash
        )
      )
      update(
        application_type: 'benefit',
        application_outcome: outcome_from_dwp_result
      )
    end
  end

  def run_income_calculation
    income_calculation_result = IncomeCalculation.new(self).calculate
    if income_calculation_result
      update_columns(
        application_type: 'income',
        application_outcome: income_calculation_result[:outcome],
        amount_to_pay: income_calculation_result[:amount]
      )
    end
  end

  def outcome_from_dwp_result
    case last_benefit_check.dwp_result
    when 'Yes'
      'full'
    when 'No'
      'none'
    end
  end

  def benefit_check_date
    if date_fee_paid.present?
      date_fee_paid
    elsif date_received.present?
      date_received
    end
  end

  def new_benefit_check_needed?
    last_benefit_check.nil? || last_benefit_check.parameter_hash != build_hash
  end

  def build_hash
    Base64.encode64([last_name, date_of_birth, ni_number, benefit_check_date].to_s)
  end

  def generate_api_token
    user = User.find(user_id)
    short_name = user.name.gsub(' ', '').downcase.truncate(27)
    "#{short_name}@#{created_at.strftime('%y%m%d%H%M%S')}.#{id}"
  end

  def active?
    status == 'active'
  end

  def active_or_status_is?(status_name)
    active? || status.to_s.include?(status_name)
  end

  def dob_age_valid?
    errors.add(:date_of_birth, "can't contain non numbers") if date_of_birth =~ /a-zA-Z/
    validate_dob_maximum unless date_of_birth.blank?
    validate_dob_minimum unless date_of_birth.blank?
  end

  def validate_dob_maximum
    if date_of_birth < Time.zone.today - MAX_AGE.years
      errors.add(
        :date_of_birth,
        I18n.t('activerecord.attributes.dwp_check.dob_too_old', max_age: MAX_AGE)
      )
    end
  end

  def validate_dob_minimum
    if date_of_birth > Time.zone.today - MIN_AGE.years
      errors.add(
        :date_of_birth,
        I18n.t('activerecord.attributes.dwp_check.dob_too_young', min_age: MIN_AGE)
      )
    end
  end

  def nullify_blank_emergency_reason
    self.emergency_reason = nil if emergency_reason.blank?
  end
end
