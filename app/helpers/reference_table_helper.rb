module ReferenceTableHelper

  def table_header
    applicant = t('processed_applications.table_header.applicant')

    if Date.today > Date.parse('2015-12-31')
      reference = t('processed_applications.table_header.reference')
      "<th> #{reference} </th>\n<th> #{applicant} </th>".html_safe
    else
      "<th> #{applicant} </th>".html_safe
    end
  end
end
