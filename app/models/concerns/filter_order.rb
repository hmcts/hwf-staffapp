module FilterOrder

  # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
  def select_order(list, show_form_name, show_court_fee, order)
    if show_form_name
      list.order(
        "detail.form_name #{order == 'Ascending' ? 'ASC' : 'DESC'}",
        "applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}"
      )
    elsif show_court_fee
      list.order(
        "detail.fee #{order == 'Ascending' ? 'ASC' : 'DESC'}",
        "applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}"
      )
    else
      list.order("applications.completed_at #{order == 'Ascending' ? 'ASC' : 'DESC'}")
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength

end
