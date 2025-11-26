# frozen_string_literal: true

# Service to load fee codes from a file or API
# Priority: 1. Load from tmp/approvedFees.json
#           2. If file doesn't exist, load from FREG API
class FeeCodesLoaderService
  FEE_CODES_FILE_PATH = Rails.root.join("tmp/approvedFees.json")
  FAKE_FEE_CODES_FILE_PATH = Rails.root.join("config/fake_fee_codes.json")

  class FeeCodesLoadError < StandardError; end

  def self.load_fees
    new.load_fees
  end

  def load_fees
    # Use fake data in development and test environments
    return load_fake_data if Rails.env.local?

    # First try to load from file
    return load_from_file if File.exist?(FEE_CODES_FILE_PATH)

    # If file doesn't exist, load from API
    Rails.logger.info "[FeeCodesLoader] File not found at #{FEE_CODES_FILE_PATH}, loading from API"
    load_from_api
  end

  private

  def load_from_file
    file_content = File.read(FEE_CODES_FILE_PATH)
    JSON.parse(file_content)
  rescue JSON::ParserError => e
    Rails.logger.error "[FeeCodesLoader] Failed to parse JSON from file: #{e.message}"
    raise FeeCodesLoadError, "Invalid JSON in fee codes file: #{e.message}"
  end

  # TODO: - since we wamt to have up to date fee codes, we should implement periodic refresh of the local file
  # but I want to keep previous files in case api call fails we would be able to load last working version
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

    # If API returns wrapped data, extract it
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
    File.write(FEE_CODES_FILE_PATH, JSON.pretty_generate(fees))
  rescue StandardError => e
    Rails.logger.error "[FeeCodesLoader] Failed to store fee codes locally: #{e.message}"
  end
end
