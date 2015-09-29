module Forms
  class Income < Base
    def self.permitted_attributes
      {
        income: Integer,
        dependents: Boolean,
        children: Integer
      }
    end

    define_attributes

    validates :dependents, inclusion: { in: [true, false] }
  end
end
