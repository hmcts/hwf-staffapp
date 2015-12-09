module ReferenceTableHelper

  def table_header
    applicant = t('processed_applications.table_header.applicant')

    if Time.zone.today > Date.parse('2015-12-31')
      reference = t('processed_applications.table_header.reference')
      "<th> #{reference} </th>\n<th> #{applicant} </th>".html_safe
    else
      "<th> #{applicant} </th>".html_safe
    end
  end

  def table_column(application)
    prefix = "<td> <a href=\"/processed_applications/#{application.id}\">"
    if Time.zone.today > Date.parse('2015-12-31')
      "#{prefix}#{application.reference}</a> </td>\n<td> #{application.applicant} </td>".html_safe
    else
      "#{prefix}#{application.applicant}</a> </td>".html_safe
    end
  end
end
