module BenefitCheckers
  class BadRequestError < StandardError
    attr_reader :response

    def initialize(message, response = nil)
      super(message)
      @response = response
    end
  end

  class BaseClient
    def check(params)
      raise NotImplementedError, "Subclasses must implement #check"
    end
  end
end
