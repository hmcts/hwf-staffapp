class OnlineApplication < ActiveRecord::Base
  acts_as_paranoid column: :purged, sentinel_value: false

  serialize :income_kind, coder: YAML
  serialize :children_age_band, coder: YAML

  belongs_to :jurisdiction, optional: true
  belongs_to :user, optional: true
  has_many :benefit_checks, as: :applicationable, dependent: :destroy
  has_many :dev_notes, as: :notable, dependent: :destroy

  validates :date_of_birth, :first_name, :last_name, :address,
            :postcode, presence: true
  validates :married, :min_threshold_exceeded, :benefits, :refund, :email_contact,
            :phone_contact, :post_contact, :feedback_opt_in, inclusion: [true, false]
  validates :reference, uniqueness: true

  validates :ni_number, presence: true, if: :check_ni_validation

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end

  def partner_full_name
    [partner_first_name, partner_last_name].compact_blank.join(' ')
  end

  def applicant
    Applicant.new(online_applicant_attributes)
  end

  # FIXME: This is here temporarily until we can refactor view models
  def detail
    self
  end

  def representative
    # TODO: placeholder for upocoming changes
  end

  def processed?
    linked_application.present? && !linked_application.created?
  end

  def linked_application(switch = '')
    return Application.with_deleted.find_by(online_application: self) if switch == :with_purged
    Application.find_by(online_application: self)
  end

  def last_benefit_check
    benefit_checks.where.not(benefits_valid: nil).where.not(dwp_result: nil).order(:id).last
  end

  def failed_because_dwp_error?
    return false if last_benefit_check.blank?
    bad_request? || benefit_check_unavailable?
  end

  def bad_request?
    last_benefit_check.dwp_result == 'BadRequest' &&
      last_benefit_check.error_message.include?('LSCBC')
  end

  def benefit_check_unavailable?
    return false if last_benefit_check.error_message.blank?
    last_benefit_check.dwp_result == 'Server unavailable' &&
      last_benefit_check.error_message.include?('The benefits checker is not available at the moment')
  end

  def benefit_check_with_error_message?
    last_benefit_check&.error_message.present?
  end

  def allow_benefit_check_override?
    benefit_check_with_error_message? || last_benefit_check&.dwp_result == 'No'
  end

  def notification_email
    legal_representative_email.presence || email_address
  end

  def formated_partner_date_of_birth
    partner_date_of_birth&.to_fs(:gov_uk_long)
  end

  def formated_partner_ni_number
    partner_ni_number&.gsub(/(.{2})/, '\1 ')
  end

  private

  def online_applicant_attributes
    fields = [:title, :first_name, :last_name, :date_of_birth, :ni_number, :ho_number, :married]
    fields.index_with { |field| send(field) }.to_h
  end

  def check_ni_validation
    return false if over_16 == false
    ho_number.blank?
  end

end
