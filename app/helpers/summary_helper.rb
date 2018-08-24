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
      content_tag(:div, class: 'summary-section') do
        content = build_header(summary_text, link_attributes)
        fields.each do |row|
          content << build_data_row(object, row)
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

  def build_header(summary_name, link_attributes)
    content_tag(:div, class: 'grid-row header-row') do
      content_tag(:div, class: 'column-two-thirds') do
        content_tag(:h4, summary_name.to_s, class: 'heading-medium util_mt-0')

      end + build_link(link_attributes)
    end
  end

  def build_link(link_attributes)
    if link_attributes[:title].present? && link_attributes[:url].present?
      link_class = 'column-one-third'
      content_tag(:div, class: link_class) do
        link_to(link_attributes[:title],
          link_attributes[:url],
          class: 'right',
          data: { section_name: link_attributes[:section_name] })
      end
    end
  end

  def build_data_row(object, field)
    label = I18n.t("activemodel.attributes.#{object.class.name.underscore}.#{field}")
    value = object.send(field)

    if value.present?
      rows = content_tag(:div, label, class: 'column-one-third')
      rows << content_tag(:div, value, class: value_style(value))

      content_tag(:div, class: 'grid-row') do
        rows
      end
    end
  end

  def value_style(value)
    ['column-two-thirds'].tap do |styles|
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
