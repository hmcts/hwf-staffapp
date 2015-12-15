module ReferenceHelper

  def after_desired_date?
    Time.zone.today > Settings.reference.date
  end

  def table_header
    applicant = t('processed_applications.table_header.applicant')

    if after_desired_date?
      reference = t('processed_applications.table_header.reference')
      "<th> #{reference} </th>\n<th> #{applicant} </th>".html_safe
    else
      "<th> #{applicant} </th>".html_safe
    end
  end

  def table_column(application)
    prefix = "<td> <a href=\"/#{controller.controller_name}/#{application.id}\">"
    if after_desired_date?
      "#{prefix}#{application.reference}</a> </td>\n<td> #{application.applicant} </td>".html_safe
    else
      "#{prefix}#{application.applicant}</a> </td>".html_safe
    end
  end

  def processing_details_options
    if after_desired_date?
      %w[processed_on processed_by reference]
    else
      %w[processed_on processed_by]
    end
  end

  def display_reference(application)
    after_desired_date? ? application.reference : ''
  end
end
