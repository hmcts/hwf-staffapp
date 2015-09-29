module Forms
  class Benefit < Base
    def self.permitted_attributes
      { benefits: Boolean }
    end

    define_attributes

    validates :benefits, inclusion: { in: [true, false] }
  end
end
