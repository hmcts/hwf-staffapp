module Forms
  class SavingsInvestment < Base

    def self.permitted_attributes
      { threshold_exceeded: Boolean }
    end

    define_attributes

    validates :threshold_exceeded, inclusion: { in: [true, false] }
  end
end
