module HomeHelper
  def path_for_application_based_on_state(application)
    case application.state
    when "waiting_for_evidence"
      waiting_for_evidence_path(application)
    when "waiting_for_part_payment"
      waiting_for_part_payment(application)
    when "processed"
      processed_application_path(application)
    when "deleted"
      deleted_application_path(application)
    end
  end

  def formatted_results_count(results)
    # I'm doing this manualy because will_paginate doesn't support the count with delimiter
    content_tag(:b, number_with_delimiter(results.total_entries)) +
      content_tag(:span, " result".pluralize(results.total_entries))
  end

  def sort_link_helper(column)
    direction = 'asc'
    if @sort_by == column.to_s
      direction = sort_direction
    end

    link = request.original_url.gsub(/(&sort_by|&sort_to)=.*/, '')
    link + "&sort_by=#{column}&sort_to=#{direction}#new_completed_search"
  end

  def sort_link_class(column)
    return 'sort_arrows' if @sort_by != column.to_s
    "sort_arrow_#{sort_direction}"
  end

  def search_table_headers
    [:reference, :entered, :first_name, :last_name,
     :case_number, :fee, :remission, :completed]
  end

  private

  def sort_direction
    @sort_to == 'desc' ? 'asc' : 'desc'
  end

  def waiting_for_evidence_path(application)
    record = Views::ApplicationList.new(application.evidence_check)
    evidence_path(record.evidence_or_part_payment)
  end

  def waiting_for_part_payment(application)
    record = Views::ApplicationList.new(application.part_payment)
    part_payment_path(record.evidence_or_part_payment)
  end
end
