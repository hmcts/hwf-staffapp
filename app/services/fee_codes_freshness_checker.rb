# frozen_string_literal: true

# Cleans up old fee code files from the tmp directory,
# keeping only the most recent one as a backup.
class FeeCodesFreshnessChecker
  FEE_CODES_DIR = FeeCodesLoaderService::FEE_CODES_DIR
  FILE_PATTERN = "approvedFees_*.json"

  def self.cleanup_old_files!(keep: 1)
    new.cleanup_old_files!(keep: keep)
  end

  def cleanup_old_files!(keep: 1)
    files = Dir.glob(FEE_CODES_DIR.join(FILE_PATTERN))
    return if files.size <= keep

    files_to_delete = files[0..-(keep + 1)]
    files_to_delete.each do |file|
      File.delete(file)
      Rails.logger.info "[FeeCodesFreshnessChecker] Deleted old fee codes file: #{file}"
    end
  end
end
