module Exceptions
  class TechnicalFaultDwpCheck < StandardError; end
  class DwpRateLimitError < StandardError; end
end
