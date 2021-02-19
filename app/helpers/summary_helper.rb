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

  def build_section_with_custom_links(summary_text, object, fields, _link_attributes = {})
    unless all_fields_empty?(object, fields)
      content_tag(:dl, class: 'govuk-summary-list') do
        content = build_header(summary_text)
        fields.each do |row|
          row[:link_attributes] = {} if row[:link_attributes].blank?
          content << build_data_row(object, row[:key], row[:link_attributes])
        end
        content
      end
    end
  end

  private

  def all_fields_empty?(object, fields)
    fields.map do |f|
      f.is_a?(Hash) ? object.send(f[:key]) : object.send(f)
    end.all?(&:blank?)
  end

  def build_header(summary_name)
    content_tag(:div, class: 'govuk-summary-list__row') do
      content_tag(:h2, summary_name.to_s, class: 'govuk-heading-m')
    end
  end

  def build_link(link_attributes, label = '')
    if link_attributes[:url].present?
      link_class = 'govuk-summary-list__actions'
      content_tag(:dd, class: link_class) do
        link_to(link_attributes[:url],
                class: 'govuk-link',
                data: { section_name: link_attributes[:section_name] }) do
          raw(format("Change%s", content_tag(:span, label.to_s, class: 'govuk-visually-hidden')))
        end
      end
    end
  end

  def build_data_row(object, field, link_attributes = {})
    value = object.send(field)
    label = single_or_plural_label(object, field, value)

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

  def single_or_plural_label(object, field, value)
    label = I18n.t("activemodel.attributes.#{object.class.name.underscore}.#{field}")
    if field == 'incorrect_reason_category' && value.try(:include?, ',')
      return label.pluralize
    end
    label
  end
end
