module Applikation
  module Forms
    class Income < ::FormObject
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
          :cant_have_children_assigned
        ) if children_declared_but_dependents_arent?
      end

      def children_declared_but_dependents_arent?
        !dependents && children.to_i > 0
      end
    end
  end
end
