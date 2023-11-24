class ApplicationBuilder

  attr_reader :application, :reference

  def initialize(current_user)
    @user = current_user
  end

  def build
    Application.new(
      office_id: @user.office_id,
      user_id: @user.id,
      applicant: build_applicant,
      detail: build_details,
      saving: build_saving,
      medium: 'paper'
    )
  end

  # rubocop:disable Metrics/MethodLength
  def build_from(online_application)
    attributes = {
      office_id: @user.office_id,
      user_id: @user.id,
      online_application: online_application,
      applicant: Applicant.new(online_applicant_attributes(online_application)),
      detail: Detail.new(online_detail_attributes(online_application)),
      saving: Saving.new(online_saving_attributes(online_application)),
      representative: Representative.new(online_representative_attributes(online_application)),
      medium: 'digital'
    }.merge(online_application_attributes(online_application))

    Application.new(attributes)
  end
  # rubocop:enable Metrics/MethodLength

  private

  def build_applicant
    Applicant.new
  end

  def build_details
    Detail.new(jurisdiction_id: @user.jurisdiction_id)
  end

  def build_saving
    Saving.new
  end

  def online_application_attributes(online_application)
    fields = [
      :benefits, :reference, :income, :income_kind,
      :income_min_threshold_exceeded, :income_max_threshold_exceeded
    ]

    prepare_attributes(fields, online_application).merge(dependent_attributes(online_application))
  end

  def dependent_attributes(online_application)
    {}.tap do |attributes|
      if online_application.children.present?
        attributes[:dependents] = online_application.children.positive?
        attributes[:children] = online_application.children
        attributes[:children_age_band] = online_application.children_age_band
      end
    end
  end

  def online_applicant_attributes(online_application)
    fields = [:title, :first_name, :last_name, :date_of_birth, :ni_number,
              :ho_number, :married, :partner_first_name, :partner_last_name, :partner_date_of_birth, :over_16]
    prepare_attributes(fields, online_application)
  end

  def online_detail_attributes(online_application)
    fields = [
      :fee, :jurisdiction, :date_received, :form_name, :case_number, :probate, :deceased_name,
      :date_of_death, :refund, :date_fee_paid, :emergency_reason, :fee_manager_firstname,
      :fee_manager_lastname, :calculation_scheme, :statement_signed_by
    ]
    prepare_attributes(fields, online_application)
  end

  def online_saving_attributes(online_application)
    fields = [:min_threshold_exceeded, :max_threshold_exceeded, :over_61, :amount]
    {
      min_threshold: Settings.savings_threshold.minimum_value,
      max_threshold: Settings.savings_threshold.maximum_value,
      choice: online_application.income_period
    }.merge(prepare_attributes(fields, online_application))
  end

  def online_representative_attributes(online_application)
    return {} if online_application.legal_representative_first_name.blank?
    {
      first_name: online_application.legal_representative_first_name,
      last_name: online_application.legal_representative_last_name,
      organisation: online_application.legal_representative_organisation_name
    }
  end

  def prepare_attributes(fields, online_application)
    fields.index_with { |field| online_application.send(field) }.to_h
  end
end
