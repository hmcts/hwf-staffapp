class ExportFileStorage < ApplicationRecord
  has_one_attached :export_file
  belongs_to :user
end
