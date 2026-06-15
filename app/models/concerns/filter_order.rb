module FilterOrder

  SECONDARY_SORT_COLUMNS = {
    'form_name' => 'details.form_name',
    'case_number' => 'details.case_number',
    'court_fee' => 'details.fee'
  }.freeze

  # Primary sort is always the processed date - newest first by default.
  # When a secondary sort is chosen the primary date is truncated to the day,
  # so applications processed on the same date are ordered by the secondary
  # field instead of their exact timestamps.
  def select_order(list, sort)
    sort ||= {}
    secondary_column = SECONDARY_SORT_COLUMNS[sort['sort_by']]

    if secondary_column
      # The DATE() truncation can't be expressed with the hash form, so this
      # branch needs raw SQL. It is safe to wrap in Arel.sql because the column
      # comes from the SECONDARY_SORT_COLUMNS allow-list and the directions are
      # always the literal 'ASC'/'DESC' - no user input reaches the string.
      list.order(Arel.sql(
                   "DATE(applications.completed_at) #{primary_direction(sort).to_s.upcase}, " \
                   "#{secondary_column} #{secondary_direction(sort).to_s.upcase}"
                 ))
    else
      list.order(completed_at: primary_direction(sort))
    end
  end

  private

  def primary_direction(sort)
    sort['order_choice'] == 'Ascending' ? :asc : :desc
  end

  def secondary_direction(sort)
    sort['sort_to'] == 'desc' ? :desc : :asc
  end
end
