module Applikation
  module Forms
    class Benefit < ::FormObject
      def self.permitted_attributes
        { benefits: Boolean }
      end

      define_attributes

      validates :benefits, inclusion: { in: [true, false] }
    end
  end
end
