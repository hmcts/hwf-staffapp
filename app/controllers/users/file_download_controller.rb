module Users
  class FileDownloadController < ApplicationController
    respond_to :html

    def show
      authorize :report, :raw_data?
      @storage = ExportFileStorage.find(params[:file_id])
    end

    def download
      @storage = ExportFileStorage.find(params[:file_id])
      authorize @storage

      send_data @storage.export_file.download, filename: 'export.zip'
    end

  end
end
