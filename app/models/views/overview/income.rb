module Views
  module Overview
    class Income < Views::Overview::Base

      def all_fields
        ['children?', 'children', 'income']
      end

      def initialize(application)
        @application = application
      end

      def children?
        convert_to_boolean(@application.dependents?)
      end

      def children
        @application.dependents? ? @application.children : 0
      end

      def income
        "£#{@application.income.try(:round)}"
      end
    end
  end
end
