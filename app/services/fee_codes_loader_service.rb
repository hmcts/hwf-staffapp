# frozen_string_literal: true

# Service to load fee codes from a file or API
# Files are stored with date stamps: tmp/approvedFees_2026-03-02.json
class FeeCodesLoaderService
  FEE_CODES_DIR = Rails.root.join("tmp")
  FAKE_FEE_CODES_FILE_PATH = Rails.root.join("config/fake_fee_codes.json")

  class FeeCodesLoadError < StandardError; end

  def self.load_fees
    new.load_fees
  end

  def self.fee_codes_file_path(date = Time.zone.today)
    FEE_CODES_DIR.join("approvedFees_#{date.strftime('%Y-%m-%d')}.json")
  end

  def load_fees
    return load_fake_data if Rails.env.test?

    file_path = self.class.fee_codes_file_path
    return load_from_file(file_path) if File.exist?(file_path)

    Rails.logger.info "[FeeCodesLoader] File not found at #{file_path}, loading from API"
    load_from_api
  end

  private

  def load_from_file(file_path)
    file_content = File.read(file_path)
    JSON.parse(file_content)
  rescue JSON::ParserError => e
    Rails.logger.error "[FeeCodesLoader] Failed to parse JSON from file: #{e.message}"
    raise FeeCodesLoadError, "Invalid JSON in fee codes file: #{e.message}"
  end

  def load_from_api
    freg_service = FregApiService.new
    response = freg_service.load_approved_feee

    if response.success?
      fees = parse_api_response(response)
      store_fees_locally(fees)
      fees
    else
      raise FeeCodesLoadError, "API request failed with status: #{response.status}"
    end
  end

  def parse_api_response(response)
    body = response.body
    return body if body.is_a?(Array)

    body['fees'] || body['data'] || []
  end

  def load_fake_data
    Rails.logger.info "[FeeCodesLoader] Loading fake fee data from #{FAKE_FEE_CODES_FILE_PATH}"
    file_content = File.read(FAKE_FEE_CODES_FILE_PATH)
    JSON.parse(file_content)
  rescue JSON::ParserError => e
    Rails.logger.error "[FeeCodesLoader] Failed to parse fake fee codes JSON: #{e.message}"
    raise FeeCodesLoadError, "Invalid JSON in fake fee codes file: #{e.message}"
  rescue StandardError => e
    Rails.logger.error "[FeeCodesLoader] Failed to read fake fee codes file: #{e.message}"
    raise FeeCodesLoadError, "Failed to read fake fee codes file: #{e.message}"
  end

  def store_fees_locally(fees)
    file_path = self.class.fee_codes_file_path
    File.write(file_path, JSON.pretty_generate(fees))
    FeeCodesFreshnessChecker.cleanup_old_files!
  rescue StandardError => e
    Rails.logger.error "[FeeCodesLoader] Failed to store fee codes locally: #{e.message}"
  end
end
