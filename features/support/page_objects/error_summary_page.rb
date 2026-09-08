class ErrorSummaryPage < BasePage
  section :error_summary, '.govuk-error-summary[data-module="govuk-error-summary"]' do
    element :title, '.govuk-error-summary__title'
    elements :messages, '.govuk-error-summary__list li'
    elements :links, '.govuk-error-summary__list a'
  end

  def shown?
    has_error_summary?
  end

  def linked_field_ids
    error_summary.links.filter_map { |link| String(link[:href])[/#(.+)\z/, 1] }
  end
end
