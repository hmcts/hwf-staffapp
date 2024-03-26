module Users
  class FileDownloadController < ApplicationController
    respond_to :html

    def show
      authorize :user
      @storage = ExportFileStorage.find(params[:file_id])
    end

    def download
      @storage_record = ExportFileStorage.find(params[:file_id])
      authorize @storage_record

      send_data @storage_record.export_file.download, filename: 'export.zip'
    end

  end
end
