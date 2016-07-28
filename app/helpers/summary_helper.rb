module SummaryHelper

  def build_section(summary_text, object, fields, link_title = nil, link_url = nil)
    content_tag(:div, class: 'summary-section') do
      content = build_header(summary_text, link_title, link_url)
      fields.each do |row|
        content << build_data_row(object, row)
      end
      content
    end
  end

  private

  def build_header(summary_name, link_title, link_url)
    content_tag(:div, class: 'grid-row header-row') do
      content_tag(:div, class: 'column-two-thirds') do
        content_tag(:h4, summary_name.to_s, class: 'heading-medium util_mt-0')
      end + build_link(link_title, link_url)
    end
  end

  def build_link(link_title, link_url)
    if link_title.present? && link_url.present?
      link_class = 'column-one-third'
      content_tag(:div, class: link_class) do
        link_to(link_title, link_url, class: 'right')
      end
    end
  end

  def build_data_row(object, field)
    label = I18n.t("activemodel.attributes.#{object.class.name.underscore}.#{field}")
    value = object.send(field)

    unless value.blank?
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
