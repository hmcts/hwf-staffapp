class DwpFailedApplicationsPage < BasePage
  set_url '/dwp_failed_applications'

  section :content, '#content' do
    element :page_header, 'H1', class: 'heading-icon-dwp_failed_applications', text: 'Pending benefit applications'
    element :sub_heading, 'caption', class: 'govuk-table__caption', text: 'Process when DWP is back online'

    section :dwp_failed_applications, '.dwp_failed_applications' do
      section :table_head, '.govuk-table__head' do
        section :heading_row, 'tr', class: 'govuk-table__row' do
          elements :heading_columns, 'th'
        end
      end

      section :table_body, '.govuk-table__body' do
        elements :table_rows, 'tr', class: 'govuk-table__row'
      end

      elements :applications, '.govuk-table__row'
      element :ready_to_process_link, 'a', class: 'blue-info-text', text: 'Ready to process'
      element :not_ready_to_process_text, 'span', class: 'red-warning-text', text: 'Not ready to process'
    end
  end

  def table_heading
    content.dwp_failed_applications.table_head.heading_row.heading_columns
  end

  def table_rows
    content.dwp_failed_applications.table_body.table_rows
  end

  def select_id_link_from_first_row
    table_rows[0].find('td:first-child').find('a').click
  end
end
