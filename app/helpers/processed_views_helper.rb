# rubocop:disable Metrics/ModuleLength
module ProcessedViewsHelper
  # rubocop:disable Rails/HelperInstanceVariable,Metrics/AbcSize,Metrics/MethodLength
  def assign_views
    @application = application
    @fee_status = Views::Overview::FeeStatus.new(application)
    @applicant = Views::Overview::Applicant.new(application)
    @online_applicant = Views::Overview::OnlineApplicant.new(application)
    @details = Views::Overview::Details.new(application)
    @savings = Views::Overview::SavingsAndInvestments.new(application.saving)
    @children = Views::Overview::Children.new(application)
    @income = Views::Overview::Income.new(application)
    @benefits = Views::Overview::Benefits.new(application)
    @application_view = Views::Overview::Application.new(application)
    @result = Views::ApplicationResult.new(application)
    @declaration = Views::Overview::Declaration.new(application)
    @representative = Views::Overview::Representative.new(build_representative(application))
    @processing_details = Views::ProcessedData.new(application)
  end
  # rubocop:enable Rails/HelperInstanceVariable,Metrics/AbcSize,Metrics/MethodLength

  def paginate(query)
    if per_page_is_all?
      query
    else
      query.paginate(page: page, per_page: per_page)
    end
  end

  def previous_page
    page - 1 if page > 1
  end

  def next_page
    page + 1 if page < total_pages
  end

  def page
    params[:page].try(:to_i) || 1
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def total_pages
    per_page_is_all? ? 1 : @paginate.total_pages
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def per_page
    params[:per_page].try(:to_i) || Settings.processed_deleted.per_page.to_i
  end

  def citizen_not_proceeding(evidence)
    evidence.try(:incorrect_reason) == 'citizen_not_processing'
  end

  def evidence_not_received(evidence)
    evidence.try(:incorrect_reason) == 'not_arrived_or_late'
  end

  def build_representative(build_from)
    if build_from.is_a?(Application) || !ucd_changes_apply?(build_from)
      build_from.representative
    else
      Representative.new(
        first_name: build_from.legal_representative_first_name,
        last_name: build_from.legal_representative_last_name,
        organisation: build_from.legal_representative_organisation_name,
        position: build_from.legal_representative_position
      )
    end
  end

  def translate_page_name(page_name)
    return 'Unknown Page' if page_name.blank?

    # Remove numeric IDs from page names (e.g., "processed_applications_450" -> "processed_applications")
    cleaned_name = page_name.gsub(/_\d+/, '')

    # Try to find a translation
    translation_key = "page_titles.#{cleaned_name}"

    if I18n.exists?(translation_key)
      I18n.t(translation_key)
    else
      # Fall back to humanized version
      cleaned_name.split('_').map(&:capitalize).join(' ')
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def format_event_name(event)
    return event.name if event.properties.blank?

    case event.name
    when 'Button Click' then format_button_click(event)
    when 'Link Click' then format_link_click(event)
    when 'Radio Selection' then format_radio_selection(event)
    when 'Checkbox Change' then format_checkbox_change(event)
    when 'Select Change' then format_select_change(event)
    when 'Form Submit' then 'Form submitted'
    when 'Paper Application Started' then 'Started paper application'
    when 'Online Application Lookup' then 'Looked up online application'
    when 'Application Search' then 'Searched for application'
    else event.name
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

  private

  def format_button_click(event)
    button_text = event.properties['button_text']
    button_text.present? ? "\"#{button_text}\" button click" : event.name
  end

  def format_link_click(event)
    link_text = event.properties['link_text']
    link_text.present? ? "\"#{link_text}\" link click" : event.name
  end

  def format_radio_selection(event)
    radio_label = event.properties['radio_label']
    radio_value = event.properties['radio_value']

    return "Selected: \"#{radio_label}\"" if radio_label.present?
    return "Selected: #{radio_value}" if radio_value.present?

    event.name
  end

  def format_checkbox_change(event)
    checkbox_label = event.properties['checkbox_label']
    return event.name if checkbox_label.blank?

    checked = event.properties['checkbox_checked']
    "#{checked ? 'Checked' : 'Unchecked'}: \"#{checkbox_label}\""
  end

  def format_select_change(event)
    select_text = event.properties['select_text']
    select_name = event.properties['select_name']

    return "Selected: \"#{select_text}\"" if select_text.present?
    return "Changed: #{select_name}" if select_name.present?

    event.name
  end

  def per_page_is_all?
    params[:per_page].eql?('All')
  end
end
# rubocop:enable Metrics/ModuleLength
