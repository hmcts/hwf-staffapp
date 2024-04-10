module FileDownloadHelper
  def download_file_page_header(storage)
    return 'Raw Data' if storage.name == 'raw_data'
    'Finance transactional' if storage.name == 'finance_transactional'
  end
end
