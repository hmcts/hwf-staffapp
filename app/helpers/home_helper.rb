module HomeHelper

  APPLICATION_STATE_LINKS = {
    waiting_for_evidence: 'waiting_for_evidence_path',
    waiting_for_part_payment: 'waiting_for_part_payment',
    processed: 'processed_application_path',
    deleted: 'deleted_application_path',
    created: 'created_application_link'
  }.freeze

  def path_for_application_based_on_state(application)
    send(APPLICATION_STATE_LINKS.fetch(application.state.to_sym), application)
  end

  def created_application_link(application)
    if application.online_application_id?
      online_application_path(application.online_application)
    else
      application_personal_informations_path(application)
    end
  end

  def formatted_results_count(results)
    # I'm doing this manualy because will_paginate doesn't support the count with delimiter
    tag.b(number_with_delimiter(results.total_entries)) +
      tag.span(" result".pluralize(results.total_entries))
  end

  def sort_link_helper(column, sort_by, sort_to = '')
    direction = 'asc'
    if sort_by == column.to_s
      direction = sort_direction(sort_to)
    end

    link = request.original_url.gsub(/(&sort_by|&sort_to)=.*/, '')
    link + "&sort_by=#{column}&sort_to=#{direction}#new_completed_search"
  end

  def sort_link_class(column, sort_by, sort_to = '')
    return 'sort_arrows' if sort_by != column.to_s
    "sort_arrow_#{sort_direction(sort_to)}"
  end

  def search_table_headers
    [:reference, :entered, :first_name, :last_name,
     :case_number, :fee, :remission, :completed]
  end

  def feedback_link
    if current_user.admin?
      feedback_display_path
    else
      feedback_path
    end
  end

  private

  def sort_direction(sort_to)
    sort_to == 'desc' ? 'asc' : 'desc'
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
