module Applikation
  module Forms
    class Benefit < ::FormObject
      def self.permitted_attributes
        { benefits: Boolean }
      end

      define_attributes

      validates :benefits, inclusion: { in: [true, false] }

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        { benefits: benefits }
      end
    end
  end
end
