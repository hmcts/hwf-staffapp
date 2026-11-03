module FileDownloadHelper
  def download_file_page_header(storage)
    return I18n.t('.users.file_download.raw_data') if storage.name == 'raw_data'
    return power_bi_export_title(storage.name.delete_prefix('power_bi_export_')) if power_bi_file?(storage)
    I18n.t('.users.file_download.finance_transactional') if storage.name == 'finance_transactional'
  end

  def power_bi_file?(storage)
    storage.name.start_with?('power_bi_export_')
  end
end
