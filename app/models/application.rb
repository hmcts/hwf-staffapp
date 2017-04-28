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
  has_one :decision_override, required: false

  scope :with_evidence_check_for_ni_number, (lambda do |ni_number|
    Application.where(state: states[:waiting_for_evidence]).
      joins(:evidence_check).
      joins(:applicant).where('applicants.ni_number = ?', ni_number)
  end)

  enum state: {
    created: 0,
    waiting_for_evidence: 1,
    waiting_for_part_payment: 2,
    processed: 3,
    deleted: 4
  }

  validates :reference, uniqueness: true, allow_blank: true

  def last_benefit_check
    benefit_checks.order(:id).last
  end

  def self.sort_received(sort_string)
    return 'details.date_received asc' if 'received_asc' == sort_string
    'details.date_received desc'
  end

  def self.sort_processed(sort_string)
    return 'completed_at asc' if 'processed_asc' == sort_string
    'completed_at desc'
  end

  def self.sort_fee(sort_string)
    return 'details.fee asc' if 'fee_asc' == sort_string
    'details.fee desc'
  end
end
