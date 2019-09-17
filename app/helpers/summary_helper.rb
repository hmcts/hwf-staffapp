module SummaryHelper

  def build_section_with_defaults(summary_text, object, link_url = nil)
    link_attributes = {}
    if link_url
      link_attributes.merge!(title: "Change #{summary_text.downcase}",
                             url: link_url,
                             section_name: summary_text.parameterize)
    end

    build_section summary_text, object, object.all_fields, link_attributes
  end

  def build_section(summary_text, object, fields, link_attributes = {})
    unless all_fields_empty?(object, fields)
      content_tag(:dl, class: 'govuk-summary-list') do
        content = build_header(summary_text)
        fields.each do |row|
          content << build_data_row(object, row, link_attributes)
        end
        content
      end
    end
  end

  def display_savings?(application)
    application.detail.discretion_applied != false
  end

  private

  def all_fields_empty?(object, fields)
    fields.map { |f| object.send(f) }.all?(&:blank?)
  end

  def build_header(summary_name)
    content_tag(:div, class: 'govuk-summary-list__row') do
      content_tag(:h2, summary_name.to_s, class: 'govuk-heading-m')
    end
  end

  def build_link(link_attributes, label = '')
    # rubocop:disable Rails/OutputSafety
    if link_attributes[:title].present? && link_attributes[:url].present?
      link_class = 'govuk-summary-list__actions'
      content_tag(:dd, class: link_class) do
        link_to(link_attributes[:url],
                class: 'govuk-link',
                data: { section_name: link_attributes[:section_name] }) do
          raw("Change" + content_tag(:span, label.to_s, class: 'govuk-visually-hidden'))
        end
      end
    end
    # rubocop:enable Rails/OutputSafety
  end

  def build_data_row(object, field, link_attributes = {})
    label = I18n.t("activemodel.attributes.#{object.class.name.underscore}.#{field}")
    value = object.send(field)

    if value.present?
      rows = content_tag(:dt, label, class: 'govuk-summary-list__key')
      rows << content_tag(:dd, value, class: value_style(value))
      rows << build_link(link_attributes, label)

      content_tag(:div, class: 'govuk-summary-list__row') do
        rows
      end
    end
  end

  def value_style(value)
    ['govuk-summary-list__value'].tap do |styles|
      case value
      when /^✓/
        styles << 'summary-result passed'
      when /^✗/
        styles << 'summary-result failed'
      when /^Waiting for/
        styles << 'summary-result part'
      end
    end.join(' ')
  end
end
