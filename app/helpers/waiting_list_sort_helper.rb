# Builds the sorting toolbar links and state for the 'Waiting for evidence'
# and 'Waiting for part-payments' lists. Primary sort is always the processed
# date; one secondary field (form name, case number or court fee) can be
# chosen with its own direction.
module WaitingListSortHelper
  SECONDARY_SORT_FIELDS = ['form_name', 'case_number', 'court_fee'].freeze

  def current_order_choice
    sort['order_choice'].presence || 'Descending'
  end

  def current_sort_by
    value = sort['sort_by'].presence
    SECONDARY_SORT_FIELDS.include?(value) ? value : nil
  end

  def current_sort_to
    sort['sort_to'] == 'desc' ? 'desc' : 'asc'
  end

  def primary_toggle_path
    waiting_list_sort_path('order_choice' => oldest_first? ? 'Descending' : 'Ascending')
  end

  # Clicking an inactive header selects that field ascending; clicking the
  # active header toggles its direction.
  def secondary_sort_path(field)
    if current_sort_by == field
      waiting_list_sort_path('sort_by' => field,
                             'sort_to' => current_sort_to == 'asc' ? 'desc' : 'asc')
    else
      waiting_list_sort_path('sort_by' => field, 'sort_to' => 'asc')
    end
  end

  def reset_sort_path
    filter_only = { 'jurisdiction_id' => selected_jurisdiction }.compact_blank
    return request.path if filter_only.empty?
    "#{request.path}?#{{ filter_applications: filter_only }.to_query}"
  end

  def oldest_first?
    current_order_choice == 'Ascending'
  end

  def primary_sort_indicator
    oldest_first? ? '▲' : '▼'
  end

  def secondary_sort_indicator(field)
    return '▲▼' unless current_sort_by == field
    current_sort_to == 'asc' ? '▲' : '▼'
  end

  def primary_header_class
    oldest_first? ? 'sort-active' : nil
  end

  def secondary_header_class(field)
    current_sort_by == field ? 'sort-active' : nil
  end

  def primary_aria_sort
    oldest_first? ? 'ascending' : 'descending'
  end

  def secondary_aria_sort(field)
    return 'none' unless current_sort_by == field
    current_sort_to == 'asc' ? 'ascending' : 'descending'
  end

  def sort_state_sentence
    sentence = t('waiting_list.sorting.sorted_by',
                 direction: t("waiting_list.sorting.#{oldest_first? ? 'oldest' : 'newest'}"))
    if current_sort_by
      direction_key = current_sort_to == 'desc' ? 'descending' : 'ascending'
      sentence += t('waiting_list.sorting.then_by_sentence',
                    field: t("waiting_list.sorting.fields.#{current_sort_by}"),
                    direction: t("waiting_list.sorting.#{direction_key}"))
    end
    "#{sentence}."
  end

  def secondary_sort_options
    SECONDARY_SORT_FIELDS.map do |field|
      [t("waiting_list.sorting.fields.#{field}"), field]
    end
  end

  private

  def waiting_list_sort_path(overrides)
    base = { 'jurisdiction_id' => selected_jurisdiction,
             'order_choice' => current_order_choice,
             'sort_by' => current_sort_by,
             'sort_to' => current_sort_by ? current_sort_to : nil }
    merged = base.merge(overrides).compact_blank
    "#{request.path}?#{{ filter_applications: merged }.to_query}"
  end
end
