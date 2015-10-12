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
    content_tag(:div, class: 'row') do
      content_tag(:div, class: 'small-12 medium-7 large-8 columns') do
        content_tag(:h4, "#{summary_name}")
      end + build_link(link_title, link_url)
    end
  end

  def build_link(link_title, link_url)
    if link_title.present? && link_url.present?
      link_class = 'small-12 medium-5 large-4 columns medium-text-right large-text-right'
      content_tag(:div, class: link_class) do
        link_to(link_title, link_url)
      end
    end
  end

  def build_data_row(object, field)
    label = I18n.t("activemodel.attributes.#{object.class.name.underscore}.#{field}")
    value = object.send(field)

    unless value.nil?
      rows = content_tag(:div, label, class: 'small-12 medium-5 large-4 columns subheader')
      rows << content_tag(:div, value, class: value_style(value))

      content_tag(:div, class: 'row') do
        rows
      end
    end
  end

  def value_style(value)
    ['small-12 medium-7 large-8 columns',
     (
      {
        '✓' => ' summary-result passed',
        '✗' => ' summary-result failed'
      }[value.to_s.first] || '')
    ].join
  end
end
