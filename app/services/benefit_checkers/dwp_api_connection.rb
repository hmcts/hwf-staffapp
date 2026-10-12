module BenefitCheckers
  # Connecting to DWP and keeping its access token between checks. Included in
  # DwpApiClient, which provides @calls (a DwpApiCallRecorder) and raise_mapped_error.
  module DwpApiConnection
    # Same margin HwfDwpApi::Authentication#expired? uses before it refreshes a token
    TOKEN_REFRESH_BUFFER = 100.seconds

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def clear_token_cache
        @cached_token = nil
      end
    end

    attr_reader :connection

    private

    def connect!
      @connection = ::HwfDwpApi.new(cached_token_attributes)
      cache_token
    rescue ::HwfDwpApiError, ::HwfDwpApiTokenError => e
      self.class.clear_token_cache
      @calls.record_error('authentication', {}, e)
      raise_mapped_error(e)
    end

    # The server can reject a cached token before it expires. See CHANGELOG.md
    def retry_once_if_token_rejected(endpoint_name, request_params)
      yield
    rescue ::HwfDwpApiTokenError => e
      @calls.record_error(endpoint_name, request_params, e)
      self.class.clear_token_cache
      connect!
      yield
    end

    # An expired cached token makes HwfDwpApi.new raise instead of refreshing. See CHANGELOG.md
    def cached_token_attributes
      cached = self.class.instance_variable_get(:@cached_token)
      return {} unless cached && cached[:expires_in] > Time.current + TOKEN_REFRESH_BUFFER

      { access_token: cached[:access_token], expires_in: cached[:expires_in] }
    end

    def cache_token
      auth = @connection.authentication
      self.class.instance_variable_set(:@cached_token, access_token: auth.access_token, expires_in: auth.expires_in)
    end
  end
end
