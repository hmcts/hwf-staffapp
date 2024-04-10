module FileDownloadHelper
  def download_file_page_header(storage)
    return I18n.t('.users.file_download.raw_data') if storage.name == 'raw_data'
    I18n.t('.users.file_download.finance_transactional') if storage.name == 'finance_transactional'
  end
end
