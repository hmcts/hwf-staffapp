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
    validates :children, numericality: { greater_than: 0, only_integer: true }, if: :dependents?
    validate :number_of_children_when_no_dependents

    private

    def number_of_children_when_no_dependents
      errors.add(
        :children,
        "you assign children if you don't have any dependants"
      ) if !dependents && children > 0
    end
  end
end
