module BenefitCheckers
  class BaseClient
    def check(params)
      raise NotImplementedError, "Subclasses must implement #check"
    end
  end
end
